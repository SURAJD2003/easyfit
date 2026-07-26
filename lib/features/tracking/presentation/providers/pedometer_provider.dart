import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../../domain/repositories/tracking_repository.dart';
import 'dashboard_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pedometerProvider = StateNotifierProvider<PedometerNotifier, AsyncValue<int>>((ref) {
  final repo = ref.watch(trackingRepositoryProvider);
  return PedometerNotifier(repo: repo);
});

/// Milestone provider — emits the milestone step count each time one is reached (1000, 2000, …)
final milestoneProvider = StateProvider<int>((ref) => 0);

class PedometerNotifier extends StateNotifier<AsyncValue<int>>
    with WidgetsBindingObserver {
  final TrackingRepository repo;
  StreamSubscription<StepCount>? _subscription;
  int _baseSteps = -1;       // raw pedometer value when session started
  int _lastSyncedSteps = 0;
  int _accumulatedSteps = 0; // steps accumulated before app was killed
  int _lastMilestone = 0;    // last celebrated milestone (1000, 2000, …)
  String _sessionDate = '';   // which day this session started
  Timer? _debounce;
  bool _isTracking = false;
  int _lastHour = -1;         // for hourly step tracking
  int _stepsAtHourStart = 0;  // steps when current hour started
  int _lastHourlyTotal = -1;  // previous total used for hourly delta allocation
  DateTime? _lastHourlyEventTime;
  int _sessionGeneration = 0;  // invalidates delayed syncs from older sessions

  // Riverpod ref for milestone updates
  StateController<int>? _milestoneController;

  PedometerNotifier({required this.repo}) : super(const AsyncValue.data(0)) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  /// Attach the milestone controller so we can push milestone events
  void attachMilestoneController(StateController<int> controller) {
    _milestoneController = controller;
  }

  Future<void> _init() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _startListening();
      // Check if there was an active session (app was killed and reopened)
      await _recoverSession();
    } else {
      state = AsyncValue.error('Activity Recognition Permission Denied', StackTrace.current);
    }
  }

  /// Handle app lifecycle — refresh from SharedPreferences when app resumes
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      _refreshFromStorage();
    }
  }

  /// Read latest step count from SharedPreferences (background service writes here)
  Future<void> _refreshFromStorage() async {
    if (!_isTracking) return;
    
    // Check midnight reset first
    await _checkMidnightReset();
    
    final prefs = await SharedPreferences.getInstance();
    final storedSteps = prefs.getInt('session_accumulated_steps') ?? 0;
    
    // Only update if stored steps are higher (background service may have advanced)
    final currentTotal = state.valueOrNull ?? 0;
    if (storedSteps > currentTotal) {
      _accumulatedSteps = storedSteps;
      _baseSteps = -1; // Reset base so next pedometer event adds on top
      state = AsyncValue.data(storedSteps);
      debugPrint('🔄 Refreshed from storage: $storedSteps steps (was $currentTotal)');
    }
    
    // Also verify session is still active
    final sessionId = prefs.getString('active_session_id');
    if (sessionId == null || sessionId.isEmpty) {
      _isTracking = false;
      debugPrint('⚠️ Session no longer active on resume');
    }
  }

  /// Check if midnight has passed — if so, reset the step count for the new day
  Future<void> _checkMidnightReset() async {
    if (!_isTracking) return;
    
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_sessionDate.isNotEmpty && _sessionDate != today) {
      debugPrint('🌙 Midnight crossed! Resetting steps ($today vs $_sessionDate)');
      
      // Do a final sync for the old day's steps before resetting
      final currentTotal = state.valueOrNull ?? 0;
      if (currentTotal > 0) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final sessionId = prefs.getString('active_session_id') ?? '';
          if (sessionId.isNotEmpty) {
            // FIX: Use hourly replay instead of single-timestamp
            // sync, which would dump all steps into a single hour.
            await repo.replayHourlyBuckets(sessionId);
          }
        } catch (e) {
          debugPrint('⚠️ Final sync for old day failed: $e');
        }
      }
      
      // Reset for new day
      _accumulatedSteps = 0;
      _baseSteps = -1;
      _lastSyncedSteps = 0;
      _lastMilestone = 0;
      _lastHour = -1;
      _stepsAtHourStart = 0;
      _lastHourlyTotal = -1;
      _lastHourlyEventTime = null;
      _sessionDate = today;
      state = const AsyncValue.data(0);
      
      // Persist the reset
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('session_accumulated_steps', 0);
      await prefs.setString('session_date', today);
      final sessionId = prefs.getString('active_session_id') ?? '';
      if (sessionId.isNotEmpty) {
        await prefs.remove('hourly_raw_steps_$sessionId');
        await prefs.remove('hourly_event_time_$sessionId');
      }
      
      debugPrint('✅ Steps reset to 0 for new day: $today');
    }
  }

  /// Recover tracking state after app restart
  Future<void> _recoverSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('active_session_id');
    if (sessionId != null && sessionId.isNotEmpty) {
      _isTracking = true;
      _accumulatedSteps = prefs.getInt('session_accumulated_steps') ?? 0;
      _sessionDate = prefs.getString('session_date') ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      _baseSteps = -1;
      _lastMilestone = (_accumulatedSteps ~/ 1000) * 1000;
      
      // Check midnight reset on recovery
      await _checkMidnightReset();
      
      state = AsyncValue.data(_accumulatedSteps);
      debugPrint('🔄 Recovered session: $sessionId with $_accumulatedSteps session steps');
    }
  }

  /// Call when the user presses PLAY (or auto-start)
  void startSession() {
    _sessionGeneration++;
    _debounce?.cancel();
    _isTracking = true;
    _baseSteps = -1;
    _accumulatedSteps = 0;
    _lastSyncedSteps = 0;
    _lastMilestone = 0;
    _lastHour = -1;
    _stepsAtHourStart = 0;
    _lastHourlyTotal = -1;
    _lastHourlyEventTime = null;
    _sessionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    state = const AsyncValue.data(0);
    // Persist initial state
    _persistSteps(0);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('session_date', _sessionDate);
    });
  }

  /// Resume an existing session WITHOUT resetting counters.
  /// Used when app resumes and the backend confirms the session is still active.
  /// This prevents the pedometer from freezing at 0 after app comes to foreground.
  void resumeSession() {
    _isTracking = true;
    // DON'T reset _baseSteps, _accumulatedSteps, or state
    // Just ensure the pedometer stream is alive
    if (_subscription == null) {
      _startListening();
    }
    // Refresh from storage in case background service updated steps
    _refreshFromStorage();
    debugPrint('🔄 Pedometer: resumed session (steps preserved: ${state.valueOrNull ?? 0})');
  }

  /// Resume tracking from a known accumulated total.
  /// Used after silent sync (stop → start) to carry forward the day's step total
  /// so new steps ADD on top instead of restarting from 0.
  void resumeWithAccumulated(int accumulatedTotal) {
    _sessionGeneration++;
    _debounce?.cancel();
    _isTracking = true;
    _accumulatedSteps = accumulatedTotal;
    _baseSteps = -1; // will re-calibrate on next pedometer event
    _lastSyncedSteps = 0; // allow immediate sync of new steps
    _lastMilestone = (accumulatedTotal ~/ 1000) * 1000;
    _sessionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    state = AsyncValue.data(accumulatedTotal);
    // Persist so BG service + crash recovery have the right starting point
    _persistSteps(accumulatedTotal);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('session_date', _sessionDate);
    });
    // Ensure pedometer stream is alive
    if (_subscription == null) {
      _startListening();
    }
    debugPrint('🔄 Pedometer: resumed with accumulated $accumulatedTotal steps');
  }

  /// Get the current session steps only (for API stop calls)
  int get currentSessionSteps {
    return state.valueOrNull ?? 0;
  }

  /// Call when the user presses STOP — freezes the counter
  void stopSession() {
    _sessionGeneration++;
    _isTracking = false;
    _debounce?.cancel();
    // Clear persisted state
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('session_accumulated_steps');
      prefs.remove('session_base_steps');
      prefs.remove('session_date');
    });
    // state stays at its last value (frozen)
  }

  /// Called at midnight to reset steps for the new day (session stays active)
  void resetForNewDay() {
    _sessionGeneration++;
    _debounce?.cancel();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    debugPrint('🌙 PedometerNotifier: resetting for new day $today');
    _accumulatedSteps = 0;
    _baseSteps = -1;
    _lastSyncedSteps = 0;
    _lastMilestone = 0;
    _lastHour = -1;
    _stepsAtHourStart = 0;
    _lastHourlyTotal = -1;
    _lastHourlyEventTime = null;
    _sessionDate = today;
    state = const AsyncValue.data(0);
    // Persist the reset
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('session_accumulated_steps', 0);
      prefs.setString('session_date', today);
      final activeSessionId = prefs.getString('active_session_id') ?? '';
      if (activeSessionId.isNotEmpty) {
        prefs.remove('hourly_raw_steps_$activeSessionId');
        prefs.remove('hourly_event_time_$activeSessionId');
      }
    });
  }

  /// Save current steps to SharedPreferences for recovery
  Future<void> _persistSteps(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('session_accumulated_steps', steps);
  }

  void _startListening() {
    _subscription?.cancel();
    _subscription = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (!_isTracking) return;

        if (_baseSteps == -1) {
          _baseSteps = event.steps;
        }
        
        // Steps since last app open + accumulated from before
        final newSteps = event.steps - _baseSteps;
        final totalSessionSteps = _accumulatedSteps + newSteps;
        state = AsyncValue.data(totalSessionSteps);
        
        // Persist every step for crash recovery
        _persistSteps(totalSessionSteps);
        
        // Keep the latest real step timestamp for sync attribution. Do not write
        // active-session steps into completed_steps_today; dashboard adds
        // completed + live, so doing that here double-counts the active session.
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('last_step_timestamp', DateTime.now().toIso8601String());
        });

        // ── Track per-hour steps ──
        _updateHourlySteps(totalSessionSteps, event.steps);

        // Check for milestone celebrations (every 1000 steps)
        _checkMilestone(totalSessionSteps);
        
        _syncWithServerThrottled(totalSessionSteps);
      },
      onError: (error) {
        debugPrint('⚠️ Pedometer stream error: $error — stream stays alive');
        // Don't set error state — keep showing last known step count
      },
      onDone: () {
        // Stream closed unexpectedly — restart after a short delay
        debugPrint('⚠️ Pedometer stream closed! Restarting in 2s...');
        Future.delayed(const Duration(seconds: 2), () {
          if (_isTracking) {
            debugPrint('🔄 Restarting pedometer listener...');
            _startListening();
          }
        });
      },
      cancelOnError: false, // CRITICAL: keep listening even after transient errors
    );
  }

  /// Check if a new 1000-step milestone was reached
  void _checkMilestone(int totalSteps) {
    final currentMilestoneLevel = (totalSteps ~/ 1000) * 1000;
    if (currentMilestoneLevel > _lastMilestone && currentMilestoneLevel > 0) {
      _lastMilestone = currentMilestoneLevel;
      debugPrint('🎉 Milestone reached: $currentMilestoneLevel steps!');
      _milestoneController?.state = currentMilestoneLevel;
    }
  }

  /// Update per-hour step counts in SharedPreferences
  void _updateHourlySteps(int totalSteps, int rawSensorSteps) {
    final now = DateTime.now();
    if (_lastHourlyTotal == -1 || _lastHourlyEventTime == null) {
      _lastHourlyTotal = totalSteps;
      _lastHourlyEventTime = now;
      _lastHour = now.hour;
      _stepsAtHourStart = totalSteps;
    }

    final previousEventTime = _lastHourlyEventTime!;
    _lastHourlyTotal = totalSteps;
    _lastHourlyEventTime = now;
    _lastHour = now.hour;

    SharedPreferences.getInstance().then((prefs) async {
      final activeSessionId = prefs.getString('active_session_id') ?? '';
      if (activeSessionId.isEmpty || activeSessionId.startsWith('local_')) {
        return;
      }

      final service = FlutterBackgroundService();
      final isBackgroundRunning = await service.isRunning();
      if (isBackgroundRunning) {
        debugPrint(
          '⏭️ FG hourly skipped: background service owns hourly buckets '
          '(session=$activeSessionId, raw=$rawSensorSteps)',
        );
        return;
      }

      final rawKey = 'hourly_raw_steps_$activeSessionId';
      final timeKey = 'hourly_event_time_$activeSessionId';
      final previousRaw = prefs.getInt(rawKey);
      final storedPreviousTime =
          DateTime.tryParse(prefs.getString(timeKey) ?? '');
      await prefs.setInt(rawKey, rawSensorSteps);
      await prefs.setString(timeKey, now.toIso8601String());

      if (previousRaw == null) {
        debugPrint(
          '🧭 FG hourly initialized: session=$activeSessionId, raw=$rawSensorSteps',
        );
        return;
      }

      final rawDelta = rawSensorSteps - previousRaw;
      if (rawDelta <= 0 || rawDelta >= 1000) {
        debugPrint(
          '⏭️ FG hourly ignored delta: session=$activeSessionId, '
          'previousRaw=$previousRaw, raw=$rawSensorSteps, delta=$rawDelta',
        );
        return;
      }

      _writeDeltaAcrossHours(
        prefs: prefs,
        sessionId: activeSessionId,
        delta: rawDelta,
        from: storedPreviousTime ?? previousEventTime,
        to: now,
        source: 'FG',
      );
    });
  }

  void _writeDeltaAcrossHours({
    required SharedPreferences prefs,
    required String sessionId,
    required int delta,
    required DateTime from,
    required DateTime to,
    required String source,
  }) {
    if (delta <= 0) return;
    if (!to.isAfter(from) || from.hour == to.hour && _isSameDay(from, to)) {
      _addHourlyDelta(prefs, sessionId, to.hour, delta, source);
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
        _addHourlyDelta(prefs, sessionId, from.hour, previousDelta, source);
      }
      if (currentDelta > 0) {
        _addHourlyDelta(prefs, sessionId, to.hour, currentDelta, source);
      }
      debugPrint(
        '🧮 HOURLY BOUNDARY SPLIT $source: session=$sessionId, '
        'from=${from.toIso8601String()}, to=${to.toIso8601String()}, '
        'delta=$delta, prevHour=${from.hour}:$previousDelta, currentHour=${to.hour}:$currentDelta',
      );
      return;
    }

    _addHourlyDelta(prefs, sessionId, to.hour, delta, source);
  }

  void _addHourlyDelta(
    SharedPreferences prefs,
    String sessionId,
    int hour,
    int delta,
    String source,
  ) {
    final prev = prefs.getInt('hourly_steps_$hour') ?? 0;
    final sessionKey = 'hourly_steps_${sessionId}_$hour';
    final prevSession = prefs.getInt(sessionKey) ?? 0;
    prefs.setInt('hourly_steps_$hour', prev + delta);
    prefs.setInt(sessionKey, prevSession + delta);
    debugPrint(
      '🧭 HOURLY BUCKET WRITE $source: session=$sessionId, '
      'hour=$hour, delta=$delta, sessionHourBefore=$prevSession, '
      'sessionHourAfter=${prevSession + delta}',
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _syncWithServerThrottled(int sessionSteps) {
    if (!_isTracking) return;
    
    // Sync if steps changed by at least 5 (lowered from 20 to catch small walks)
    if ((sessionSteps - _lastSyncedSteps).abs() > 5) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      final scheduledGeneration = _sessionGeneration;
      _debounce = Timer(const Duration(seconds: 2), () async {
        if (!_isTracking || scheduledGeneration != _sessionGeneration) {
          return;
        }
        try {
          final prefs = await SharedPreferences.getInstance();
          final sessionId = prefs.getString('active_session_id') ?? '';
          if (sessionId.isNotEmpty && _isTracking && scheduledGeneration == _sessionGeneration) {
            final storedSessionSteps = prefs.getInt('session_accumulated_steps') ?? 0;
            final stepsToSync = sessionSteps > storedSessionSteps ? sessionSteps : storedSessionSteps;
            debugPrint(
              '🔎 FG SYNC RECONCILE: session=$sessionId, '
              'sessionSteps=$sessionSteps, storedSessionSteps=$storedSessionSteps, '
              'stepsToSync=$stepsToSync, lastSynced=$_lastSyncedSteps',
            );
            if (stepsToSync > sessionSteps) {
              _accumulatedSteps = stepsToSync;
              _baseSteps = -1;
              state = AsyncValue.data(stepsToSync);
              debugPrint('🔄 FG sync caught up from background: $sessionSteps → $stepsToSync');
            }
            // ═══════════════════════════════════════════════════
            // FIX: Use hourly replay instead of single-timestamp
            //   sync. Sending ALL steps with current timestamp
            //   overwrites the per-hour distribution.
            // ═══════════════════════════════════════════════════
            await repo.replayHourlyBuckets(sessionId);
            _lastSyncedSteps = stepsToSync;
            debugPrint('✅ FG Sync: $stepsToSync steps (via hourly replay)');
          }
        } catch (e) {
          debugPrint('❌ FG Sync failed: $e');
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
