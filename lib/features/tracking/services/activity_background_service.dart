import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pedometer/pedometer.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  final FlutterLocalNotificationsPlugin notifPlugin = FlutterLocalNotificationsPlugin();
  await notifPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  int baseSteps = -1;
  int currentSteps = 0;
  int accumulatedBefore = 0;
  int lastSyncedTotal = -1;   // Track last synced value to avoid duplicates
  String sessionDate = '';     // Track which day this session belongs to
  DateTime sessionStart = DateTime.now();
  StreamSubscription<StepCount>? pedometerSub;
  Timer? syncTimer;

  // Recover accumulated steps from the foreground
  final prefsInit = await SharedPreferences.getInstance();
  final sessionAccumulated = prefsInit.getInt('session_accumulated_steps') ?? 0;
  accumulatedBefore = sessionAccumulated;
  sessionDate = prefsInit.getString('session_date') ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  debugPrint('🔄 BG: Started with accumulatedBefore=$accumulatedBefore');

  // Check if there's actually an active session
  final sessionId = prefsInit.getString('active_session_id');
  if (sessionId == null || sessionId.isEmpty) {
    debugPrint('⚠️ BG: No active session, stopping service');
    service.stopSelf();
    return;
  }

  // ── FORMAT DURATION ──
  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  // ── NOTIFICATION (Premium UI) ──
  // Uses async to read SharedPreferences so the notification matches the dashboard total
  void updateNotification() async {
    // bgSteps is the CURRENT SESSION'S total
    final bgSteps = accumulatedBefore + currentSteps;
    
    // dashboardSteps is the day's total before the current session started
    final prefs = await SharedPreferences.getInstance();
    final dashboardSteps = prefs.getInt('completed_steps_today') ?? 0;
    
    // Display the daily total to the user in the notification
    final totalDailySteps = dashboardSteps + bgSteps;
    
    final elapsed = DateTime.now().difference(sessionStart);
    final duration = _formatDuration(elapsed);
    final calories = (totalDailySteps * 0.045).round();
    final distance = (totalDailySteps * 0.000762).toStringAsFixed(2);
    
    // Build a clean, informative notification
    final title = '🏃 $totalDailySteps steps  ·  $duration';
    final body = '🔥 $calories kcal  ·  📍 ${distance} km  ·  Tracking active';
    
    notifPlugin.show(
      888,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tracking_channel',
          'Activity Tracking',
          icon: '@mipmap/ic_launcher',
          ongoing: true,
          importance: Importance.low,
          priority: Priority.low,
          showWhen: false,
          styleInformation: BigTextStyleInformation(''),
          colorized: true,
          color: Color(0xFFFF6B2B),
        ),
      ),
    );
  }

  // ── MIDNIGHT CHECK ──
  // Checks if we've crossed midnight; if so, auto-reset steps for the new day
  Future<bool> _checkMidnightReset() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (sessionDate != today) {
      debugPrint('🌙 Midnight crossed! Resetting steps for new day ($sessionDate → $today)');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final currentSessionId = prefs.getString('active_session_id') ?? '';
      
      // Save final steps for the old day by doing a STOP session
      final totalSteps = accumulatedBefore + currentSteps;
      if (totalSteps > 0 && currentSessionId.isNotEmpty && token.isNotEmpty) {
        try {
          final dio = Dio(BaseOptions(
            baseUrl: 'https://uat-api.theeasyfitclinics.com/api',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ));
          
          // STOP the session → commits steps to stats/reports
          await dio.patch('/activity/session/stop', data: {
            'sessionId': currentSessionId,
            'endTime': DateTime.now().subtract(const Duration(seconds: 1)).toIso8601String(),
            'finalSteps': totalSteps,
            'finalCalories': (totalSteps * 0.045).round(),
            'finalDistance': double.parse((totalSteps * 0.000762).toStringAsFixed(3)),
          });
          debugPrint('✅ Midnight: stopped old day session with $totalSteps steps');
          
          // START a fresh session for the new day
          final startResp = await dio.post('/activity/session/start', data: {
            'startTime': DateTime.now().toIso8601String(),
            'baselineSteps': 0,
          });
          
          // Parse the new session ID
          dynamic respData = startResp.data;
          if (respData is String) {
            try { respData = jsonDecode(respData); } catch (_) {}
          }
          final newSessionId = (respData is Map) ? (respData['sessionId'] ?? respData['id'] ?? '') : '';
          if (newSessionId.toString().isNotEmpty) {
            await prefs.setString('active_session_id', newSessionId.toString());
            debugPrint('✅ Midnight: started new day session: $newSessionId');
          }
        } catch (e) {
          debugPrint('⚠️ Midnight stop/start failed: $e');
        }
      }
      
      // Reset for the new day
      accumulatedBefore = 0;
      currentSteps = 0;
      baseSteps = -1;
      lastSyncedTotal = -1;
      sessionDate = today;
      sessionStart = DateTime.now();
      
      // Persist the reset
      await prefs.setInt('session_accumulated_steps', 0);
      await prefs.setString('session_date', today);
      await prefs.setInt('synced_steps_offset', 0);
      // Clear hourly step data for the new day
      for (int h = 0; h < 24; h++) {
        await prefs.remove('hourly_steps_\$h');
      }
      
      updateNotification();
      return true;
    }
    return false;
  }

  // Listen to pedometer with auto-reconnection (Samsung kills sensor streams)
  int lastPedometerValue = -1;
  
  void startPedometer() {
    pedometerSub?.cancel();
    pedometerSub = Pedometer.stepCountStream.listen((StepCount event) {
      if (baseSteps == -1) {
        baseSteps = event.steps;
      }
      currentSteps = event.steps - baseSteps;
      
      // Calculate raw delta for hourly tracking (immune to session restarts)
      int rawDelta = 0;
      if (lastPedometerValue != -1) {
        rawDelta = event.steps - lastPedometerValue;
      }
      lastPedometerValue = event.steps;
      
      // Persist total for the foreground to pick up
      final totalSteps = accumulatedBefore + currentSteps;
      SharedPreferences.getInstance().then((p) {
        p.setInt('session_accumulated_steps', totalSteps);
        
        // ── Track per-hour steps (Delta Method) ──
        if (rawDelta > 0 && rawDelta < 1000) { // filter out massive boot jumps
          final nowHour = DateTime.now().hour;
          final prevHourSteps = p.getInt('hourly_steps_$nowHour') ?? 0;
          p.setInt('hourly_steps_$nowHour', prevHourSteps + rawDelta);
        }
      });
      
      updateNotification();
    },
    onError: (error) {
      debugPrint('⚠️ BG Pedometer error: $error — restarting in 3s');
      Future.delayed(const Duration(seconds: 3), () => startPedometer());
    },
    onDone: () {
      debugPrint('⚠️ BG Pedometer stream closed — restarting in 3s');
      Future.delayed(const Duration(seconds: 3), () => startPedometer());
    },
    cancelOnError: false,
    );
  }
  startPedometer();

  // Initial notification
  updateNotification();

  // Background sync loop — ONLY syncs when steps actually changed
  syncTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
    try {
      // Check midnight reset first
      await _checkMidnightReset();
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final currentSessionId = prefs.getString('active_session_id');
      
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ BG: No auth token');
        return;
      }
      if (currentSessionId == null || currentSessionId.isEmpty) {
        debugPrint('⚠️ BG: Session ended, stopping service');
        pedometerSub?.cancel();
        syncTimer?.cancel();
        notifPlugin.cancel(888);
        service.stopSelf();
        return;
      }
      
      // If session is a local offline one, try to swap it for a real backend session.
      // If that fails (still offline), skip the sync but keep counting locally.
      if (currentSessionId.startsWith('local_')) {
        debugPrint('📴 BG: Local session detected, attempting to get real session...');
        try {
          final dio = Dio(BaseOptions(
            baseUrl: 'https://uat-api.theeasyfitclinics.com/api',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ));
          
          final startResp = await dio.post('/activity/session/start', data: {
            'startTime': DateTime.now().toIso8601String(),
            'baselineSteps': 0,
          });
          
          dynamic respData = startResp.data;
          if (respData is String) {
            try { respData = await Future.value(respData).then((_) => startResp.data is String ? {} : startResp.data); } catch (_) {}
          }
          final realSessionId = (respData is Map) ? (respData['sessionId'] ?? respData['id'] ?? '') : '';
          if (realSessionId.toString().isNotEmpty) {
            await prefs.setString('active_session_id', realSessionId.toString());
            debugPrint('✅ BG: Swapped local → real session: $realSessionId');
            // Don't return — continue to sync with the new real session ID below
          } else {
            debugPrint('⚠️ BG: No session ID returned, skipping sync');
            return;
          }
        } catch (e) {
          debugPrint('📴 BG: Still offline, skipping sync — steps counting locally');
          return; // Stay alive, retry next cycle
        }
      }
      
      // Re-read session ID in case we just swapped it
      final activeSessionId = prefs.getString('active_session_id') ?? '';
      if (activeSessionId.isEmpty || activeSessionId.startsWith('local_')) {
        return; // Safety check
      }
      
      // We sync bgSteps (which is ONLY the current session's steps) to the backend.
      // The backend expects session steps and will sum them to get the daily total.
      final bgSteps = accumulatedBefore + currentSteps;
      
      // ✅ SKIP sync if steps haven't changed since last sync
      if (bgSteps == lastSyncedTotal) {
        debugPrint('⏭️ BG: Skipping sync — no new steps ($bgSteps)');
        return;
      }
      
      final calories = (bgSteps * 0.045).round();
      final distance = double.parse((bgSteps * 0.000762).toStringAsFixed(3));
      
      final dio = Dio(BaseOptions(
        baseUrl: 'https://uat-api.theeasyfitclinics.com/api',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ));
      
      final syncData = {
        'sessionId': activeSessionId,
        'steps': bgSteps,
        'calories': calories,
        'distance': distance,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      debugPrint('\n🚀 REALTIME JSON TO BACKEND:\n${jsonEncode(syncData)}\n');

      await dio.post('/activity/sync', data: syncData);
      
      lastSyncedTotal = bgSteps;
      debugPrint('✅ BG Sync: $bgSteps steps (synced)');
    } catch (e) {
      debugPrint('❌ BG Sync Error: $e');
    }
  });

  // Stop handler
  service.on('stopService').listen((event) {
    pedometerSub?.cancel();
    syncTimer?.cancel();
    notifPlugin.cancel(888);
    service.stopSelf();
  });
}

class ActivityBackgroundService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tracking_channel',
      'Activity Tracking',
      description: 'Maintains the background pedometer loop',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'tracking_channel',
        initialNotificationTitle: '🏃 EasyFit Activity',
        initialNotificationContent: 'Preparing tracker...',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.health],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
      ),
    );

    // Auto-restart service if there's an active session from before
    final prefs = await SharedPreferences.getInstance();
    final activeSessionId = prefs.getString('active_session_id');
    if (activeSessionId != null && activeSessionId.isNotEmpty) {
      debugPrint('🔄 Auto-restarting background service for session: $activeSessionId');
      final isRunning = await service.isRunning();
      if (!isRunning) {
        service.startService();
      }
    }
  }
}
