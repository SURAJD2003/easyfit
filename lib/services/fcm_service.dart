// lib/services/fcm_service.dart
// Handles Firebase Cloud Messaging — silent push sync + token registration
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

/// Top-level background message handler (must be a top-level function)
/// This runs even when the app is killed/terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('═══════════════════════════════════════════');
  debugPrint('📩 FCM BACKGROUND MESSAGE RECEIVED');
  debugPrint('   Message ID: ${message.messageId}');
  debugPrint('   Data: ${message.data}');
  debugPrint('   From: ${message.from}');
  debugPrint('   Sent Time: ${message.sentTime}');
  debugPrint('═══════════════════════════════════════════');

  final type = message.data['type'] ?? message.data['Type'] ?? '';
  debugPrint('📩 FCM message type: "$type"');

  if (type == 'sync_request' || type == 'sync_steps') {
    debugPrint('🔄 FCM: Triggering silent sync...');
    await _performSilentSync();
  } else {
    debugPrint('ℹ️ FCM: Unknown message type "$type", ignoring');
  }
}

bool _isFcmSyncing = false;

/// Reads the latest step count from SharedPreferences and sends it to the backend.
/// This is the exact same logic as the background service's sync,
/// but triggered by a silent push instead of a timer.
Future<void> _performSilentSync() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final token = prefs.getString('auth_token') ?? '';
    final sessionId = prefs.getString('active_session_id') ?? '';

    debugPrint('📊 FCM Sync Check:');
    debugPrint('   Auth token present: ${token.isNotEmpty}');
    debugPrint('   Session ID: $sessionId');
    debugPrint('   Is local session: ${sessionId.startsWith('local_')}');

    if (token.isEmpty) {
      debugPrint('⚠️ FCM sync SKIPPED: No auth token');
      return;
    }
    if (sessionId.isEmpty) {
      debugPrint('⚠️ FCM sync SKIPPED: No active session');
      return;
    }
    if (sessionId.startsWith('local_')) {
      debugPrint('⚠️ FCM sync SKIPPED: Local offline session');
      return;
    }

    final steps = prefs.getInt('session_accumulated_steps') ?? 0;

    debugPrint('📊 FCM Step Data:');
    debugPrint('   session_accumulated_steps: $steps');
    debugPrint('   Steps to sync: $steps');

    if (steps <= 0) {
      debugPrint('⏭️ FCM sync SKIPPED: No steps to sync (0)');
      return;
    }

    final service = FlutterBackgroundService();
    final isBackgroundRunning = await service.isRunning();
    if (isBackgroundRunning) {
      debugPrint('⏭️ FCM sync SKIPPED: Background service is already running and owns syncing');
      return;
    }

    if (_isFcmSyncing) {
      debugPrint('⏭️ FCM sync SKIPPED: FCM sync already in progress');
      return;
    }
    _isFcmSyncing = true;
    
    final calories = (steps * 0.045).round();
    final distance = double.parse((steps * 0.000762).toStringAsFixed(3));

    // Build hourlyData array with DELTAS for array-based sync
    final now = DateTime.now();
    final dio = Dio(BaseOptions(
      baseUrl: 'https://uat-api.theeasyfitclinics.com/api',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ));

    final List<Map<String, dynamic>> hourlyData = [];
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

    if (hourlyData.isEmpty) {
      debugPrint('⏭️ FCM: No hourly deltas to send');
      return;
    }

    final payload = {
      'sessionId': sessionId,
      'hourlyData': hourlyData,
    };

    debugPrint('🚀 FCM SYNC REQUEST (Array):');
    debugPrint('   Payload: ${jsonEncode(payload)}');

    final response = await dio.post('/activity/sync', data: payload);

    debugPrint('✅ FCM SYNC SUCCESS:');
    debugPrint('   Status: ${response.statusCode}');
    debugPrint('   Response: ${response.data}');

    // SUCCESS — mark deltas as synced
    for (final bucket in hourlyData) {
      final h = bucket['hour'] as int;
      final syncedKey = 'synced_hourly_steps_${sessionId}_$h';
      final bucketKey = 'hourly_steps_${sessionId}_$h';
      final currentTotal = prefs.getInt(bucketKey) ?? 0;
      await prefs.setInt(syncedKey, currentTotal);
    }
    debugPrint('✅ FCM Array Sync: Sent ${hourlyData.length} buckets');
    } catch (e) {
      debugPrint('❌ FCM SYNC FAILED:');
      debugPrint('   Error: $e');
      if (e is DioException) {
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response: ${e.response?.data}');
      }
    } finally {
      _isFcmSyncing = false;
    }
}

/// Service class to initialize FCM and handle token registration
class FcmService {
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FcmService._();

  /// Initialize FCM: request permissions, get token, set up handlers
  Future<void> initialize() async {
    try {
      debugPrint('═══════════════════════════════════════════');
      debugPrint('🔥 FCM SERVICE: Initializing...');
      debugPrint('═══════════════════════════════════════════');

      final messaging = FirebaseMessaging.instance;

      // Request permission (required for iOS, auto-granted on Android for data messages)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('🔔 FCM Permission status: ${settings.authorizationStatus}');

      // Get the FCM token
      final fcmToken = await messaging.getToken();
      debugPrint('═══════════════════════════════════════════');
      debugPrint('🔑 FCM TOKEN: $fcmToken');
      debugPrint('═══════════════════════════════════════════');

      // Save locally
      if (fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', fcmToken);
        debugPrint('💾 FCM Token saved to SharedPreferences');
      } else {
        debugPrint('⚠️ FCM Token is null — this should not happen');
      }

      // Listen for token refreshes
      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('🔄 FCM Token REFRESHED: $newToken');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', newToken);
        await _sendTokenToBackend(newToken);
      });

      // Handle foreground messages (app is open)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('═══════════════════════════════════════════');
        debugPrint('📩 FCM FOREGROUND MESSAGE RECEIVED');
        debugPrint('   Message ID: ${message.messageId}');
        debugPrint('   Data: ${message.data}');
        debugPrint('   Notification: ${message.notification?.title ?? 'none'}');
        debugPrint('═══════════════════════════════════════════');

        final type = message.data['type'] ?? message.data['Type'] ?? '';
        if (type == 'sync_request' || type == 'sync_steps') {
          debugPrint('🔄 FCM foreground: Triggering silent sync...');
          _performSilentSync();
        } else {
          debugPrint('ℹ️ FCM foreground: Message type "$type", no sync needed');
        }
      });

      // Handle messages when app is opened from background via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📩 FCM: App opened from notification tap');
        debugPrint('   Data: ${message.data}');
      });

      // Register the background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      debugPrint('✅ FCM background handler registered');

      // Send token to backend
      if (fcmToken != null) {
        await _sendTokenToBackend(fcmToken);
      }

      debugPrint('═══════════════════════════════════════════');
      debugPrint('🔥 FCM SERVICE: Initialization COMPLETE');
      debugPrint('═══════════════════════════════════════════');
    } catch (e) {
      debugPrint('═══════════════════════════════════════════');
      debugPrint('❌ FCM SERVICE: Initialization FAILED');
      debugPrint('   Error: $e');
      debugPrint('═══════════════════════════════════════════');
    }
  }

  /// Send the FCM token to the backend so it can send pushes to this device
  Future<void> _sendTokenToBackend(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? '';

      debugPrint('📤 FCM: Sending token to backend...');
      debugPrint('   Auth token present: ${authToken.isNotEmpty}');
      debugPrint('   FCM token: ${fcmToken.substring(0, 20)}...');

      if (authToken.isEmpty) {
        debugPrint('⚠️ FCM: No auth token, skipping backend registration (user not logged in yet)');
        return;
      }

      final dio = Dio(BaseOptions(
        baseUrl: 'https://uat-api.theeasyfitclinics.com/api',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ));

      final payload = {
        'fcmToken': fcmToken,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
      };
      debugPrint('📤 FCM: POST /notifications/register');
      debugPrint('   Payload: ${jsonEncode(payload)}');

      final response = await dio.post('/notifications/register', data: payload);

      debugPrint('✅ FCM TOKEN REGISTERED WITH BACKEND:');
      debugPrint('   Status: ${response.statusCode}');
      debugPrint('   Response: ${response.data}');
    } catch (e) {
      debugPrint('⚠️ FCM TOKEN REGISTRATION:');
      debugPrint('   Error: $e');
      if (e is DioException) {
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response: ${e.response?.data}');
      }
      debugPrint('   (Non-fatal — backend may not have /device-tokens endpoint yet)');
    }
  }

  /// Re-register token (call after login)
  Future<void> registerToken() async {
    debugPrint('🔄 FCM: Re-registering token after login...');
    final prefs = await SharedPreferences.getInstance();
    final fcmToken = prefs.getString('fcm_token');
    if (fcmToken != null) {
      await _sendTokenToBackend(fcmToken);
    } else {
      debugPrint('⚠️ FCM: No token to re-register');
    }
  }
}
