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
  String boundSessionId = sessionId ?? '';
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
    await prefs.reload();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final completedDate = prefs.getString('completed_steps_date') ?? '';
    final dashboardSteps = completedDate == today ? (prefs.getInt('completed_steps_today') ?? 0) : 0;
    final apiDate = prefs.getString('last_known_today_api_date') ?? '';
    final apiSteps = apiDate == today ? (prefs.getInt('last_known_today_api_steps') ?? 0) : 0;
    
    // Display the same guarded daily total as the dashboard.
    final localDailySteps = dashboardSteps + bgSteps;
    final totalDailySteps = bgSteps == 0 && apiSteps > 0 && dashboardSteps > apiSteps
        ? apiSteps
        : (apiSteps > localDailySteps ? apiSteps : localDailySteps);
    debugPrint(
      '🔔 NOTIFICATION TOTAL DEBUG: session=$boundSessionId, '
      'completed=$dashboardSteps(date=$completedDate), bgSteps=$bgSteps, '
      'api=$apiSteps(date=$apiDate), localDaily=$localDailySteps, '
      'shown=$totalDailySteps',
    );
    
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
            boundSessionId = newSessionId.toString();
            
            // Fix: Reset pedometer memory so yesterday's steps do not leak into the new day's session
            baseSteps = -1;
            currentSteps = 0;
            accumulatedBefore = 0;
            await prefs.setInt('session_accumulated_steps', 0);
            
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
      for (final key in prefs.getKeys().where((key) => key.startsWith('hourly_')).toList()) {
        await prefs.remove(key);
      }
      
      updateNotification();
      return true;
    }
    return false;
  }

  // Listen to pedometer with auto-reconnection (Samsung kills sensor streams)
  Future<void> addHourlyDelta(SharedPreferences prefs, String sessionId, int hour, int delta, String source) async {
    final prevHourSteps = prefs.getInt('hourly_steps_$hour') ?? 0;
    final sessionKey = 'hourly_steps_${sessionId}_$hour';
    final prevSessionHourSteps = prefs.getInt(sessionKey) ?? 0;
    await prefs.setInt('hourly_steps_$hour', prevHourSteps + delta);
    await prefs.setInt(sessionKey, prevSessionHourSteps + delta);
    debugPrint(
      '🧭 HOURLY BUCKET WRITE $source: session=$sessionId, '
      'hour=$hour, delta=$delta, sessionHourBefore=$prevSessionHourSteps, '
      'sessionHourAfter=${prevSessionHourSteps + delta}',
    );
  }

  Future<void> writeDeltaAcrossHours({
    required SharedPreferences prefs,
    required String sessionId,
    required int delta,
    required DateTime from,
    required DateTime to,
    required String source,
  }) async {
    if (delta <= 0) return;
    if (!to.isAfter(from) ||
        (from.hour == to.hour &&
            from.day == to.day &&
            from.month == to.month &&
            from.year == to.year)) {
      await addHourlyDelta(prefs, sessionId, to.hour, delta, source);
      return;
    }

    final boundary = DateTime(to.year, to.month, to.day, to.hour);
    if (boundary.isAfter(from) && boundary.isBefore(to)) {
      final totalMs = to.difference(from).inMilliseconds;
      final previousMs =
          boundary.difference(from).inMilliseconds.clamp(0, totalMs).toInt();
      final previousDelta =
          ((delta * previousMs) / totalMs).round().clamp(0, delta).toInt();
      final currentDelta = delta - previousDelta;
      if (previousDelta > 0) {
        await addHourlyDelta(prefs, sessionId, from.hour, previousDelta, source);
      }
      if (currentDelta > 0) {
        await addHourlyDelta(prefs, sessionId, to.hour, currentDelta, source);
      }
      debugPrint(
        '🧮 HOURLY BOUNDARY SPLIT $source: session=$sessionId, '
        'from=${from.toIso8601String()}, to=${to.toIso8601String()}, '
        'delta=$delta, prevHour=${from.hour}:$previousDelta, currentHour=${to.hour}:$currentDelta',
      );
      return;
    }

    await addHourlyDelta(prefs, sessionId, to.hour, delta, source);
  }
  
  void startPedometer() {
    pedometerSub?.cancel();
    pedometerSub = Pedometer.stepCountStream.listen((StepCount event) {
      final eventTime = DateTime.now();
      if (baseSteps == -1) {
        baseSteps = event.steps;
      }
      currentSteps = event.steps - baseSteps;
      
      // Persist total for the foreground to pick up
      final totalSteps = accumulatedBefore + currentSteps;
      SharedPreferences.getInstance().then((p) async {
        await p.setInt('session_accumulated_steps', totalSteps);
        await p.setString('last_step_timestamp', eventTime.toIso8601String());
        
        // ── Track per-hour steps (Delta Method) ──
        if (boundSessionId.isEmpty || boundSessionId.startsWith('local_')) {
          return;
        }

        final rawKey = 'hourly_raw_steps_$boundSessionId';
        final timeKey = 'hourly_event_time_$boundSessionId';
        final previousRaw = p.getInt(rawKey);
        final previousEventTime = DateTime.tryParse(p.getString(timeKey) ?? '');
        await p.setInt(rawKey, event.steps);
        await p.setString(timeKey, eventTime.toIso8601String());

        if (previousRaw == null) {
          debugPrint('🧭 BG hourly initialized: session=$boundSessionId, raw=${event.steps}');
          return;
        }

        final rawDelta = event.steps - previousRaw;
        if (rawDelta <= 0 || rawDelta >= 1000) {
          debugPrint(
            '⏭️ BG hourly ignored delta: session=$boundSessionId, '
            'previousRaw=$previousRaw, raw=${event.steps}, delta=$rawDelta',
          );
          return;
        }

        await writeDeltaAcrossHours(
          prefs: p,
          sessionId: boundSessionId,
          delta: rawDelta,
          from: previousEventTime ?? eventTime,
          to: eventTime,
          source: 'BG',
        );
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

  // ═══════════════════════════════════════════════════════════════════
  // 🔥 BACKGROUND SYNC LOOP — REPLAYS HOURLY BUCKETS
  //
  // OLD BUG: Previously this sent ALL session steps with a single
  //   current timestamp every 2 seconds. This caused the backend to
  //   dump ALL steps into the current hour, wiping out earlier hours.
  //
  // FIX: Now replays per-hour buckets with per-hour timestamps,
  //   so steps walked at 4:55 PM stay in Hour 16 and steps walked
  //   at 5:05 PM go into Hour 17.
  // ═══════════════════════════════════════════════════════════════════
  bool _isBgSyncing = false;
  syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (_isBgSyncing) {
      debugPrint('⏭️ BG: Sync already in progress, skipping timer tick');
      return;
    }
    _isBgSyncing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      await prefs.setBool('is_bg_syncing', true);
      debugPrint('🔒 BG LOCK: Acquired cross-isolate lock (is_bg_syncing=true)');
      
      // Check midnight reset first
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
      
      if (currentSessionId != boundSessionId) {
        debugPrint('BG: Session changed ($boundSessionId -> $currentSessionId), stopping stale service');
        pedometerSub?.cancel();
        syncTimer?.cancel();
        notifPlugin.cancel(888);
        service.stopSelf();
        return;
      }
      
      // If session is a local offline one, try to swap it for a real backend session.
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
            try { respData = jsonDecode(respData); } catch (_) {}
          }
          final realSessionId = (respData is Map) ? (respData['sessionId'] ?? respData['id'] ?? '') : '';
          if (realSessionId.toString().isNotEmpty) {
            await prefs.setString('active_session_id', realSessionId.toString());
            boundSessionId = realSessionId.toString();
            debugPrint('✅ BG: Swapped local → real session: $realSessionId');
          } else {
            debugPrint('⚠️ BG: No session ID returned, skipping sync');
            return;
          }
        } catch (e) {
          debugPrint('📴 BG: Still offline, skipping sync — steps counting locally');
          return;
        }
      }
      
      // Re-read session ID in case we just swapped it
      final activeSessionId = prefs.getString('active_session_id') ?? '';
      if (activeSessionId.isEmpty || activeSessionId.startsWith('local_')) {
        return;
      }
      
      final bgSteps = accumulatedBefore + currentSteps;
      
      // SKIP sync if steps haven't changed since last sync
      if (bgSteps == lastSyncedTotal) {
        debugPrint('⏭️ BG: Skipping sync — no new steps ($bgSteps)');
        return;
      }
      
      final dio = Dio(BaseOptions(
        baseUrl: 'https://uat-api.theeasyfitclinics.com/api',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ));
      
      // ── Build hourlyData array with DELTAS ──
      final now = DateTime.now();
      final List<Map<String, dynamic>> hourlyData = [];

      for (int h = 0; h <= now.hour; h++) {
        final bucketKey = 'hourly_steps_${activeSessionId}_$h';
        final syncedKey = 'synced_hourly_steps_${activeSessionId}_$h';
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
        debugPrint('⏭️ BG: No hourly deltas to send');
        return;
      }

      try {
        await dio.post('/activity/sync', data: {
          'sessionId': activeSessionId,
          'hourlyData': hourlyData,
        });

        // SUCCESS — mark deltas as synced
        for (final bucket in hourlyData) {
          final h = bucket['hour'] as int;
          final syncedKey = 'synced_hourly_steps_${activeSessionId}_$h';
          final bucketKey = 'hourly_steps_${activeSessionId}_$h';
          final currentTotal = prefs.getInt(bucketKey) ?? 0;
          await prefs.setInt(syncedKey, currentTotal);
        }

        lastSyncedTotal = bgSteps;
        debugPrint('✅ BG Array Sync: Sent ${hourlyData.length} buckets');
      } catch (e) {
        debugPrint('⚠️ BG Array sync failed: $e');
      }
    } catch (e) {
      debugPrint('❌ BG Sync Error: $e');
    } finally {
      _isBgSyncing = false;
      SharedPreferences.getInstance().then((p) {
        p.setBool('is_bg_syncing', false);
        debugPrint('🔓 BG LOCK: Released cross-isolate lock (is_bg_syncing=false)');
      });
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
