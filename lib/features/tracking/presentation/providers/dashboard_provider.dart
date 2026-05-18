import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/activity_remote_datasource.dart';
import '../../data/repositories/tracking_repository_impl.dart';
import '../../domain/repositories/tracking_repository.dart';
import 'dashboard_state.dart';

final remoteDatasourceProvider = Provider<ActivityRemoteDatasource>((ref) {
  return ActivityRemoteDatasource();
});

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  final ds = ref.watch(remoteDatasourceProvider);
  return TrackingRepositoryImpl(remoteDatasource: ds);
});

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repo = ref.watch(trackingRepositoryProvider);
  return DashboardNotifier(repo: repo);
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  final TrackingRepository repo;
  Timer? _autoRefreshTimer;

  DashboardNotifier({required this.repo}) : super(DashboardState()) {
    _init();
  }

  /// Start auto-refreshing today's stats every 30 seconds (call when tracking starts)
  void startAutoRefresh() {
    stopAutoRefresh(); // cancel any existing timer
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh();
    });
    print('🔄 Auto-refresh started (every 30s)');
  }

  /// Stop auto-refreshing (call when tracking stops)
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  /// Lightweight refresh — only fetches today's activity (used during live tracking)
  Future<void> refreshToday() async {
    try {
      // Check if day has changed — if so, do a full refresh
      final localToday = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (_lastFetchDate.isNotEmpty && _lastFetchDate != localToday) {
        print('🌙 Day changed during auto-refresh ($localToday vs $_lastFetchDate), doing full refresh');
        await _init();
        return;
      }
      
      final today = await repo.getTodayActivity();
      if (mounted) {
        state = state.copyWith(todayActivity: today);
      }
      print('🔄 Auto-refreshed today: $today');
    } catch (e) {
      print('❌ Auto-refresh error: $e');
    }
  }

  String _lastFetchDate = ''; // track which date we last fetched for

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, error: null);
    
    Map<String, dynamic>? today;
    Map<String, dynamic>? weekly;
    Map<String, dynamic>? monthly;
    List<dynamic>? historyList;

    final now = DateTime.now();
    final localToday = DateFormat('yyyy-MM-dd').format(now);
    _lastFetchDate = localToday;
    
    // Current week: Monday to Sunday
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    // Current month: 1st to last day
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final fmt = DateFormat('yyyy-MM-dd');
    
    try { 
      today = await repo.getTodayActivity(); 
      print('📊 TODAY API response: $today');
    } catch (e) { print('❌ TODAY API error: $e'); }
    
    try { 
      weekly = await repo.getWeeklyStats(
        startDate: fmt.format(weekStart),
        endDate: fmt.format(weekEnd),
      ); 
      print('📊 WEEKLY API response: $weekly');
    } catch (e) { print('❌ WEEKLY API error: $e'); }
    
    try { 
      monthly = await repo.getMonthlyStats(
        startDate: fmt.format(monthStart),
        endDate: fmt.format(monthEnd),
      ); 
      print('📊 MONTHLY API response: $monthly');
    } catch (e) { print('❌ MONTHLY API error: $e'); }
    
    try { 
      final historyMap = await repo.getActivityHistory(); 
      print('📊 HISTORY API response: $historyMap');
      historyList = historyMap['data'] ?? historyMap['sessions'] ?? [];
    } catch (e) { print('❌ HISTORY API error: $e'); }
    
    state = state.copyWith(
      todayActivity: today,
      weeklyStats: weekly,
      monthlyStats: monthly,
      history: historyList ?? [],
      isLoading: false,
      error: null,
    );
    print('📊 Final DashboardState → today: ${state.todayActivity}, weekly: ${state.weeklyStats}');
  }

  /// Fetch weekly stats for a specific date range
  Future<void> fetchWeeklyStats(DateTime weekStart, DateTime weekEnd) async {
    state = state.copyWith(isLoading: true);
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final weekly = await repo.getWeeklyStats(
        startDate: fmt.format(weekStart),
        endDate: fmt.format(weekEnd),
      );
      print('📊 WEEKLY API (${fmt.format(weekStart)} → ${fmt.format(weekEnd)}): $weekly');
      state = state.copyWith(weeklyStats: weekly, isLoading: false);
    } catch (e) {
      print('❌ WEEKLY fetch error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Fetch monthly stats for a specific date range
  Future<void> fetchMonthlyStats(DateTime monthStart, DateTime monthEnd) async {
    state = state.copyWith(isLoading: true);
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final monthly = await repo.getMonthlyStats(
        startDate: fmt.format(monthStart),
        endDate: fmt.format(monthEnd),
      );
      print('📊 MONTHLY API (${fmt.format(monthStart)} → ${fmt.format(monthEnd)}): $monthly');
      state = state.copyWith(monthlyStats: monthly, isLoading: false);
    } catch (e) {
      print('❌ MONTHLY fetch error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await _init();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
