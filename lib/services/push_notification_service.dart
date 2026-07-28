import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../core/api_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  
  final type = message.data['type'] ?? message.data['Type'] ?? '';
  if (type == 'sync_request' || type == 'sync_steps') {
    debugPrint('🔄 FCM BACKGROUND: Triggering silent pedometer sync...');
    await _performSilentSync();
  }
}

bool _isFcmSyncing = false;

Future<void> _performSilentSync() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final token = prefs.getString('auth_token') ?? '';
    final sessionId = prefs.getString('active_session_id') ?? '';

    if (token.isEmpty || sessionId.isEmpty || sessionId.startsWith('local_')) {
      return;
    }

    final steps = prefs.getInt('session_accumulated_steps') ?? 0;
    if (steps <= 0) return;

    final service = FlutterBackgroundService();
    final isBackgroundRunning = await service.isRunning();
    if (isBackgroundRunning) return;

    if (_isFcmSyncing) return;
    _isFcmSyncing = true;
    
    final dio = Dio(BaseOptions(
      baseUrl: 'https://uat-api.theeasyfitclinics.com/api',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ));

    final List<Map<String, dynamic>> hourlyData = [];
    final now = DateTime.now();
    for (int h = 0; h <= now.hour; h++) {
      final bucketKey = 'hourly_steps_${sessionId}_$h';
      final syncedKey = 'synced_hourly_steps_${sessionId}_$h';
      final totalSteps = prefs.getInt(bucketKey) ?? 0;
      final alreadySynced = prefs.getInt(syncedKey) ?? 0;
      final delta = totalSteps - alreadySynced;

      if (delta > 0) {
        final deltaCals = (delta * 0.045).round();
        final deltaDist = double.parse((delta * 0.000762).toStringAsFixed(3));
        hourlyData.add({
          'hour': h,
          'steps': delta,
          'calories': deltaCals,
          'distance': deltaDist,
        });
      }
    }

    if (hourlyData.isEmpty) return;

    final payload = {
      'sessionId': sessionId,
      'hourlyData': hourlyData,
    };

    final response = await dio.post('/activity/sync', data: payload);

    if (response.statusCode == 200 || response.statusCode == 201) {
      for (final bucket in hourlyData) {
        final h = bucket['hour'] as int;
        final syncedKey = 'synced_hourly_steps_${sessionId}_$h';
        final bucketKey = 'hourly_steps_${sessionId}_$h';
        final currentTotal = prefs.getInt(bucketKey) ?? 0;
        await prefs.setInt(syncedKey, currentTotal);
      }
      debugPrint('✅ FCM Silent Sync Success');
    }
  } catch (e) {
    debugPrint('❌ FCM Silent Sync Failed: $e');
  } finally {
    _isFcmSyncing = false;
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      debugPrint('Push notifications are not fully supported on this platform yet.');
      return;
    }

    try {
      // 1. Request Permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      debugPrint('User granted permission: ${settings.authorizationStatus}');

      // 2. Initialize Local Notifications (for foreground notifications)
      const androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInitialize = DarwinInitializationSettings();
      const initializationsSettings = InitializationSettings(
        android: androidInitialize,
        iOS: iosInitialize,
      );

      await _localNotificationsPlugin.initialize(
        initializationsSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create a high importance channel for Android
      const channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.', // description
        importance: Importance.max,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Configure FCM foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        
        final type = message.data['type'] ?? message.data['Type'] ?? '';
        if (type == 'sync_request' || type == 'sync_steps') {
          debugPrint('🔄 FCM FOREGROUND: Triggering silent pedometer sync...');
          _performSilentSync();
        }

        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification}');
          _showLocalNotification(message, channel);
        }
      });

      // 4. Handle initial message (if app was opened via a notification)
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage.data);
      }

      // 5. Handle messages when app is in background but opened by clicking notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationClick(message.data);
      });

      // 6. Get the FCM Token
      final token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      
      // We will register the token with the backend separately after login
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing PushNotificationService: $e');
    }
  }

  Future<void> registerTokenWithBackend() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null) return;
      
      final dio = ApiClient().dio;
      // Also try to get admin token if it exists
      final prefs = await SharedPreferences.getInstance();
      final authStr = prefs.getString('auth_token');
      final adminStr = prefs.getString('admin_token');
      final activeToken = authStr ?? adminStr;
      
      if (activeToken != null) {
        // Temporarily set the token in Dio for this request if ApiClient doesn't have it
        dio.options.headers['Authorization'] = 'Bearer $activeToken';
      }

      await dio.post('/notifications/register', data: {
        'fcmToken': token,
        'platform': Platform.operatingSystem,
      });
      debugPrint('Successfully registered FCM token with backend.');
    } catch (e) {
      debugPrint('Failed to register FCM token with backend: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message, AndroidNotificationChannel channel) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null && !kIsWeb) {
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationClick(data);
      } catch (e) {
        debugPrint('Error decoding notification payload: $e');
      }
    }
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    debugPrint('Notification clicked with data: $data');
    // Implement navigation logic here based on data payload
  }
}
