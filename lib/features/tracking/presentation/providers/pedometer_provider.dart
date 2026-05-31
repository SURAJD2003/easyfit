import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
            final calories = (currentTotal * 0.045).round();
            final distance = double.parse((currentTotal * 0.000762).toStringAsFixed(3));
            await repo.syncSteps(
              sessionId: sessionId,
              steps: currentTotal,
              calories: calories,
              distance: distance,
            );
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
      _sessionDate = today;
      state = const AsyncValue.data(0);
      
      // Persist the reset
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('session_accumulated_steps', 0);
      await prefs.setString('session_date', today);
      
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
    _isTracking = true;
    _baseSteps = -1;
    _accumulatedSteps = 0;
    _lastSyncedSteps = 0;
    _lastMilestone = 0;
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
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    debugPrint('🌙 PedometerNotifier: resetting for new day $today');
    _accumulatedSteps = 0;
    _baseSteps = -1;
    _lastSyncedSteps = 0;
    _lastMilestone = 0;
    _lastHour = -1;
    _stepsAtHourStart = 0;
    _sessionDate = today;
    state = const AsyncValue.data(0);
    // Persist the reset
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('session_accumulated_steps', 0);
      prefs.setString('session_date', today);
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
        
        // Also write to completed_steps_today so BG notification + stats screen
        // always have the latest foreground total
        SharedPreferences.getInstance().then((prefs) {
          final existing = prefs.getInt('completed_steps_today') ?? 0;
          if (totalSessionSteps > existing) {
            prefs.setInt('completed_steps_today', totalSessionSteps);
          }
        });

        // ── Track per-hour steps ──
        _updateHourlySteps(totalSessionSteps);

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
  void _updateHourlySteps(int totalSteps) {
    final nowHour = DateTime.now().hour;
    if (_lastHour == -1) {
      _lastHour = nowHour;
      _stepsAtHourStart = totalSteps;
    }
    if (nowHour != _lastHour) {
      _stepsAtHourStart = totalSteps;
      _lastHour = nowHour;
    }
    final hourDelta = totalSteps - _stepsAtHourStart;
    if (hourDelta > 0) {
      SharedPreferences.getInstance().then((prefs) {
        final prev = prefs.getInt('hourly_steps_$nowHour') ?? 0;
        if (hourDelta > prev) {
          prefs.setInt('hourly_steps_$nowHour', hourDelta);
        }
      });
    }
  }

  void _syncWithServerThrottled(int sessionSteps) {
    if (!_isTracking) return;
    
    // Sync if steps changed by at least 5 (lowered from 20 to catch small walks)
    if ((sessionSteps - _lastSyncedSteps).abs() > 5) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 2), () async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final sessionId = prefs.getString('active_session_id') ?? '';
          if (sessionId.isNotEmpty && _isTracking) {
            final calories = (sessionSteps * 0.045).round();
            final distance = double.parse((sessionSteps * 0.000762).toStringAsFixed(3));
            await repo.syncSteps(
                sessionId: sessionId,
                steps: sessionSteps,
                calories: calories,
                distance: distance);
            _lastSyncedSteps = sessionSteps;
            debugPrint('✅ FG Sync: $sessionSteps steps');
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
