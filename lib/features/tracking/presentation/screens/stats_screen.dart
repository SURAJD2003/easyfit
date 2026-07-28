import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../providers/pedometer_provider.dart';


class _T {
  static const bg        = Color(0xFF0A0A0A);
  static const card      = Color(0xFF141414);
  static const card2     = Color(0xFF1C1C1C);
  static const divider   = Color(0xFF252525);
  static const hi        = Color(0xFFFFFFFF);
  static const mid       = Color(0xFF8A8A8A);
  static const lo        = Color(0xFF3A3A3A);
  static const accent    = Color(0xFFFF6B2B);
  static const accentDim = Color(0x1AFF6B2B);
  static const green     = Color(0xFF30D158);
  static const blue      = Color(0xFF0A84FF);
  static const purple    = Color(0xFFBF5AF2);
  static const gold      = Color(0xFFFFCC00);
  static const accentGrad = LinearGradient(
    colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}


// ══════════════════════════════════════════════════════════
//  STATS SCREEN
// ══════════════════════════════════════════════════════════
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {

  int _tabIndex      = 1;
  late int _selectedPeriod;
  int _listTab       = 0;
  int _activeCard    = 0; // 0=Steps, 1=Distance, 2=Calories
  int _currentPhaseLevel = 0; // persisted phase level (same as dashboard)
  int _cachedCompletedSteps = 0; // Local cache for step alignment

  // Phase goals matching dashboard
  static const _phaseGoals = [5000, 7000, 10000, 12000, 15000];

  void _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _cachedCompletedSteps = prefs.getInt('completed_steps_today') ?? 0);
  }

  // ══════════════════════════════════════════════════════════
  //  API-ALIGNED DATA — maps to real server response schemas
  // ══════════════════════════════════════════════════════════

  // ── /api/activity/today response ──
  // { "steps": 0, "calories": 0, "distance": 0,
  //   "activeMinutes": 0, "goalSteps": 0, "goalProgress": 0 }
  Map<String, dynamic>? get _todayData => ref.watch(dashboardProvider).todayActivity;
  
  // Use the SAME max-of-all-sources formula as the dashboard hero card
  // so stats screen always shows the same number.
  int get _todaySteps {
    final apiSteps = (_todayData?['steps'] ?? 0) as int;
    final pedometerSteps = ref.watch(pedometerProvider).valueOrNull ?? 0;
    if (pedometerSteps == 0 && apiSteps > 0 && _cachedCompletedSteps > apiSteps) {
      return apiSteps;
    }
    final liveDailyTotal = _cachedCompletedSteps + pedometerSteps;
    return math.max(apiSteps, liveDailyTotal);
  }
  // For calories and distance: if our MAX steps is higher than API steps,
  // derive calories/distance from steps (same formula as dashboard hero card)
  double get _todayCalories {
    final apiCals = ((_todayData?['calories'] ?? 0) as num).toDouble();
    final derivedCals = _todaySteps * 0.045;
    return [apiCals, derivedCals].reduce((a, b) => a > b ? a : b);
  }
  double get _todayDistance {
    final apiDist = ((_todayData?['distance'] ?? 0) as num).toDouble();
    final derivedDist = _todaySteps * 0.000762;
    return [apiDist, derivedDist].reduce((a, b) => a > b ? a : b);
  }
  int    get _todayActive    => (_todayData?['activeMinutes'] ?? 0) as int;
  int    get _todayGoal      => (_todayData?['goalSteps'] as num?)?.toInt() ?? _phaseGoals[_currentPhaseLevel.clamp(0, 4)];
  double get _todayProgress  => ((_todayData?['goalProgress'] ?? 0) as num).toDouble();

  // ── Hourly step data (loaded from API) ──
  List<double> _hourlySteps = List.filled(24, 0.0);
  bool _hourlyLoaded = false;
  Map<String, dynamic>? _dailyStatsData; // raw API response for debug

  void _loadHourlySteps() async {
    if (_hourlyLoaded) return;
    _hourlyLoaded = true;

    final repo = ref.read(trackingRepositoryProvider);
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Replay local hourly buckets to ensure backend has all hourly timestamps
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeSessionId = prefs.getString('active_session_id') ?? '';
      if (activeSessionId.isNotEmpty) {
        await repo.syncHourlyBuckets(activeSessionId);
      }
    } catch (e) {
      debugPrint('⚠️ [StatsScreen] Hourly replay error: $e');
    }

    debugPrint('📊 [StatsScreen] Loading hourly steps from API for $today');

    try {
      final data = await repo.getDailyStats(date: today);
      _dailyStatsData = data;

      debugPrint('📊 [StatsScreen] Daily stats API response: $data');

      final hours = data['hours'] as List?;
      if (hours == null || hours.isEmpty) {
        debugPrint('⚠️ [StatsScreen] No hours data in response');
        if (mounted) setState(() => _hourlySteps = List.filled(24, 0.0));
        return;
      }

      debugPrint('');
      debugPrint('═══════════════════════════════════════════');
      debugPrint('🔬 STATS SCREEN HOURLY RESPONSE FROM BACKEND:');
      debugPrint('   Date: $today');
      debugPrint('   Total steps reported by API: ${data['totalSteps']}');
      
      final List<double> hourly = List.filled(24, 0.0);
      for (final h in hours) {
        final hourIndex = (h['hour'] as num?)?.toInt() ?? -1;
        final steps = (h['steps'] as num?)?.toDouble() ?? 0.0;
        if (hourIndex >= 0 && hourIndex < 24) {
          hourly[hourIndex] = steps;
          if (steps > 0 || (h['hasActivity'] == true)) {
            debugPrint('   👉 Bucket Hour $hourIndex (${h['label']}): $steps steps (hasActivity=${h['hasActivity']})');
          }
        }
      }
      debugPrint('═══════════════════════════════════════════');
      debugPrint('');

      if (mounted) setState(() => _hourlySteps = hourly);
    } catch (e) {
      debugPrint('❌ [StatsScreen] Daily stats API failed: $e — showing zeros');
      if (mounted) setState(() => _hourlySteps = List.filled(24, 0.0));
    }
  }

  // ── Chart bar data per tab ──
  List<double> get _stepBars {
    final state = ref.watch(dashboardProvider);
    if (_tabIndex == 0) {
      // Day view: use per-hour data
      _loadHourlySteps();
      return _hourlySteps;
    } else if (_tabIndex == 1) {
      // Week view: GET /api/activity/stats/weekly
      // Response: { "days": [{"date":"...","steps":0,"calories":0}],
      //             "totalSteps":0, "totalCalories":0, "avgStepsPerDay":0 }
      final weekly = state.weeklyStats;
      if (weekly == null) return List.filled(7, 0.0);
      final days = weekly['days'] as List?;
      if (days != null) {
        // Pad to 7 if server returns fewer days
        final result = List.filled(7, 0.0);
        for (int i = 0; i < days.length && i < 7; i++) {
          result[i] = ((days[i]['steps'] ?? 0) as num).toDouble();
        }
        return result;
      }
      return List.filled(7, 0.0);
    } else {
      // Month view: GET /api/activity/stats/monthly
      // Response: { weeks: [{weekStart, weekEnd, steps, calories}], totalSteps, totalCalories, avgStepsPerDay }
      final monthly = state.monthlyStats;
      if (monthly == null) return List.filled(5, 0.0);
      final weeks = monthly['weeks'] as List?;
      if (weeks != null && weeks.isNotEmpty) {
        return weeks.map((w) => ((w['steps'] ?? 0) as num).toDouble()).toList();
      }
      return List.filled(5, 0.0);
    }
  }

  // Distance & calories from steps (fallback math if API doesn't split by hour)
  List<double> get _distBars  => _stepBars.map((s) => double.parse((s * 0.000762).toStringAsFixed(2))).toList();
  List<double> get _calBars   => _stepBars.map((s) => double.parse((s * 0.045).toStringAsFixed(1))).toList();

  // Active bars for the chart widget
  List<double> get _bars {
    if (_activeCard == 1) return _distBars;
    if (_activeCard == 2) return _calBars;
    return _stepBars;
  }

  List<String> get _xLabels {
    if (_tabIndex == 0) return ['0', '4', '8', '12', '16', '20', '24'];
    if (_tabIndex == 1) {
      final weekly = ref.watch(dashboardProvider).weeklyStats;
      final days = weekly?['days'] as List?;
      if (days != null && days.isNotEmpty) {
        return days.map((d) {
          final dtStr = d['date'] ?? '';
          try {
            final dt = DateTime.parse(dtStr);
            return DateFormat('E').format(dt).substring(0, 1);
          } catch (_) {}
          return '-';
        }).toList();
      }
      return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    }
    // Month: generate week labels from API data
    final monthly = ref.watch(dashboardProvider).monthlyStats;
    final weeks = monthly?['weeks'] as List?;
    if (weeks != null && weeks.isNotEmpty) {
      return weeks.map((w) {
        final ws = w['weekStart'] ?? '';
        try {
          final dt = DateTime.parse(ws);
          return DateFormat('d MMM').format(dt);
        } catch (_) {}
        return 'W';
      }).toList();
    }
    return ['W1', 'W2', 'W3', 'W4', 'W5'];
  }

  List<String> get _periodPills {
    final now = DateTime.now();
    if (_tabIndex == 0) {
      // Day: just show today
      return ['TODAY'];
    }
    if (_tabIndex == 1) {
      // Week: rolling 7-day windows — LAST 7 DAYS first, then older
      final List<String> pills = [];
      for (int i = 0; i < 8; i++) {
        final we = now.subtract(Duration(days: 7 * i));
        final ws = we.subtract(const Duration(days: 6));
        if (i == 0) {
          pills.add('LAST 7 DAYS');
        } else {
          pills.add('${DateFormat('d MMM').format(ws).toUpperCase()} – ${DateFormat('d MMM').format(we).toUpperCase()}');
        }
      }
      return pills;
    }
    // Month: current month first, then older
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final result = months.sublist(0, now.month).reversed.toList();
    return result;
  }

  /// Get the date range for the selected period pill
  void _fetchForSelectedPeriod() {
    final now = DateTime.now();
    final notifier = ref.read(dashboardProvider.notifier);
    final fmt = DateFormat('yyyy-MM-dd');

    if (_tabIndex == 0) {
      // Day: just refresh today
      return;
    }
    if (_tabIndex == 1) {
      // Week: rolling 7-day windows (today and 6 days back)
      final weeksBack = _selectedPeriod;
      final we = now.subtract(Duration(days: 7 * weeksBack));
      final ws = we.subtract(const Duration(days: 6));
      notifier.fetchWeeklyStats(ws, we);
      return;
    }
    // Month: pills go [current month, previous, ...]
    final month = now.month - _selectedPeriod; // selectedPeriod 0 = current month
    final start = DateTime(now.year, month, 1);
    final end = DateTime(now.year, month + 1, 0);
    notifier.fetchMonthlyStats(start, end);
  }

  // ── Summary totals (use API values directly) ──
  double get _totalSteps {
    if (_tabIndex == 0) return _todaySteps.toDouble();
    if (_tabIndex == 1) {
      final weekly = ref.watch(dashboardProvider).weeklyStats;
      return ((weekly?['totalSteps'] ?? 0) as num).toDouble();
    }
    // Month: use API totalSteps
    final monthly = ref.watch(dashboardProvider).monthlyStats;
    return ((monthly?['totalSteps'] ?? 0) as num).toDouble();
  }
  double get _totalDist {
    if (_tabIndex == 0) return _todayDistance;
    if (_tabIndex == 2) {
      return _totalSteps * 0.000762;
    }
    return _distBars.fold(0.0, (a, b) => a + b);
  }
  int get _totalCals {
    if (_tabIndex == 0) return _todayCalories.round();
    if (_tabIndex == 1) {
      final weekly = ref.watch(dashboardProvider).weeklyStats;
      return ((weekly?['totalCalories'] ?? 0) as num).round();
    }
    // Month: use API totalCalories
    final monthly = ref.watch(dashboardProvider).monthlyStats;
    return ((monthly?['totalCalories'] ?? 0) as num).round();
  }

  String get _stepsStr => _totalSteps >= 1000
      ? '${(_totalSteps / 1000).toStringAsFixed(_totalSteps % 1000 == 0 ? 0 : 1)}k'
      : _totalSteps.toInt().toString();
  String get _distStr  => _totalDist.toStringAsFixed(1);
  String get _calsStr  => _totalCals.toString();

  // Chart title + subtitle
  String get _chartTitle {
    if (_activeCard == 1) return 'Distance';
    if (_activeCard == 2) return 'Calories';
    return 'Steps';
  }

  String get _statSubtitle {
    if (_tabIndex == 0) {
      return '$_todayActive active minutes  •  Goal: $_todayGoal steps';
    }
    if (_tabIndex == 1) {
      final weekly = ref.watch(dashboardProvider).weeklyStats;
      final avg = (weekly?['avgStepsPerDay'] ?? 0) as num;
      return 'Avg: ${avg.round()} steps / day';
    }
    // Month
    final monthly = ref.watch(dashboardProvider).monthlyStats;
    final avg = (monthly?['avgStepsPerDay'] ?? 0) as num;
    final activeCard = _activeCard;
    if (activeCard == 1) {
      return 'Avg: ${(avg.toDouble() * 0.000762).toStringAsFixed(2)} km / day';
    }
    if (activeCard == 2) {
      return 'Avg: ${(avg.toDouble() * 0.045).round()} kcal / day';
    }
    return 'Avg: ${avg.round()} steps / day';
  }

  // Chart bar color per active card
  Color get _chartColor {
    if (_activeCard == 1) return _T.blue;
    if (_activeCard == 2) return _T.green;
    return _T.accent;
  }

  String get _listLabel => _tabIndex == 0 ? 'Hourly' : 'Day Wise';

  List<Map<String, String>> get _listItems {
    final state = ref.watch(dashboardProvider);
    
    String formatVal(double steps) {
      if (_activeCard == 1) return '${(steps * 0.000762).toStringAsFixed(2)} km';
      if (_activeCard == 2) return '${(steps * 0.045).round()} kcal';
      return '${steps.toInt()} steps';
    }

    if (_listTab == 1) {
      // 4. GET /api/activity/history
      final history = state.history ?? [];
      return history.map<Map<String, String>>((h) {
        return {
          'val': '${h['duration_seconds'] ?? 0}s (${h['type'] ?? 'Session'})',
          'sub': '${h['start_time'] ?? 'Unknown'}',
          'id': '${h['id'] ?? ''}'
        };
      }).toList();
    }

    // _listTab == 0
    final hours = ['12 am','1 am','2 am','3 am','4 am','5 am','6 am','7 am','8 am','9 am','10 am','11 am','12 pm','1 pm','2 pm','3 pm','4 pm','5 pm','6 pm','7 pm','8 pm','9 pm','10 pm','11 pm'];
    final weekDays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

    if (_tabIndex == 0) {
      final bars = _stepBars;
      return List.generate(bars.length, (i) {
        if (bars[i] == 0) return null;
        return {'val': formatVal(bars[i]), 'sub': '${hours[i]} to ${hours[(i + 1) % 24]}', 'id': ''};
      }).whereType<Map<String, String>>().toList();
    }
    if (_tabIndex == 1) {
      final weekly = state.weeklyStats;
      final days = (weekly?['days'] as List?) ?? [];
      final bars = _stepBars;
      final now = DateTime.now();
      final items = List.generate(bars.length, (i) {
        if (bars[i] == 0) return null;
        String dayName = 'Day ${i + 1}';
        bool isToday = false;
        if (i < days.length && days[i]['date'] != null) {
          try {
            final dt = DateTime.parse(days[i]['date'] as String);
            isToday = (dt.year == now.year && dt.month == now.month && dt.day == now.day);
            dayName = isToday ? '${DateFormat('E').format(dt)} (Today)' : DateFormat('E').format(dt);
          } catch (_) {}
        }
        return {'val': formatVal(bars[i]), 'sub': dayName, 'id': '', 'isToday': isToday ? 'true' : 'false'};
      }).whereType<Map<String, String>>().toList();
      return items.reversed.toList();
    }
    // Month: show weekly breakdown
    final monthly = state.monthlyStats;
    final weeks = (monthly?['weeks'] as List?) ?? [];
    return List.generate(weeks.length, (i) {
      final w = weeks[i] as Map<String, dynamic>;
      final steps = (w['steps'] ?? 0) as num;
      if (steps == 0) return null;
      String label = 'Week ${i + 1}';
      try {
        final ws = DateTime.parse(w['weekStart']);
        final we = DateTime.parse(w['weekEnd']);
        label = '${DateFormat('d MMM').format(ws)} – ${DateFormat('d MMM').format(we)}';
      } catch (_) {}
      return {'val': formatVal(steps.toDouble()), 'sub': label, 'id': ''};
    }).whereType<Map<String, String>>().toList();
  }

  @override
  void initState() {
    super.initState();
    _selectedPeriod = 0; // Start on THIS WEEK / TODAY / current month
    _hourlyLoaded = false; // Always reload hourly data when stats screen opens
    _loadPhaseLevel(); // load persisted phase level
    _loadCache(); // load completed steps for MAX formula
    // Trigger a fresh API fetch, then load correct data for the selected period
    Future.microtask(() async {
      await ref.read(dashboardProvider.notifier).refresh();
      _fetchForSelectedPeriod();
    });
  }

  /// Load persisted phase level from SharedPreferences
  Future<void> _loadPhaseLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('current_phase_level') ?? 0;
    if (mounted) setState(() => _currentPhaseLevel = saved);
  }

  void _switchTab(int i) {
    if (i == _tabIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _tabIndex = i;
      _selectedPeriod = 0; // Always start at the most recent period
      _listTab = 0;
      if (i == 0) _hourlyLoaded = false; // reload hourly data
    });
    _fetchForSelectedPeriod();
  }

  void _switchCard(int i) {
    HapticFeedback.lightImpact();
    setState(() => _activeCard = i);
  }

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardProvider);
    
    double _swipeStartX = 0;

    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _appBar(),
            const SizedBox(height: 16),
            _tabRow(),
            const SizedBox(height: 12),
            Expanded(
              child: dashState.isLoading
                ? const Center(child: CircularProgressIndicator(color: _T.accent))
                : GestureDetector(
                    onHorizontalDragStart: (d) => _swipeStartX = d.globalPosition.dx,
                    onHorizontalDragEnd: (d) {
                      final velocity = d.primaryVelocity ?? 0;
                      if (velocity < -300 && _tabIndex < 2) {
                        _switchTab(_tabIndex + 1); // swipe left → next tab
                      } else if (velocity > 300 && _tabIndex > 0) {
                        _switchTab(_tabIndex - 1); // swipe right → prev tab
                      }
                    },
                    child: RefreshIndicator(
                      color: _T.accent,
                      backgroundColor: _T.card,
                      onRefresh: () async {
                        _hourlyLoaded = false; // reload hourly data on refresh
                        await ref.read(dashboardProvider.notifier).refresh();
                        _fetchForSelectedPeriod();
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          children: [
                            _periodPillsRow(),
                            const SizedBox(height: 16),
                            _statCards(),
                            const SizedBox(height: 20),
                            _chartSection(),
                            const SizedBox(height: 24),
                            _listSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ──
  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(RouteNames.dashboard),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _T.card,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.chevron_left_rounded, color: _T.hi, size: 22),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('History', style: GoogleFonts.inter(
                fontSize: 17, fontWeight: FontWeight.w700, color: _T.hi,
              )),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ── TAB ROW ──
  Widget _tabRow() {
    final tabs = ['Day', 'Week', 'Month'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == _tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchTab(i),
              child: Column(
                children: [
                  Text(tabs[i], style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active ? _T.hi : _T.mid,
                  )),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 2,
                    decoration: BoxDecoration(
                      color: active ? _T.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── PERIOD PILLS ──
  Widget _periodPillsRow() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: _periodPills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = i == _selectedPeriod;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedPeriod = i);
              _fetchForSelectedPeriod();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: active ? _T.accent : _T.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? _T.accent : _T.divider),
              ),
              child: Text(_periodPills[i], style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: active ? Colors.white : _T.mid,
              )),
            ),
          );
        },
      ),
    );
  }

  // ── 3 STAT CARDS ──
  Widget _statCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          _statCard(0, _stepsStr, 'Steps',         _T.accent),
          const SizedBox(width: 10),
          _statCard(1, _distStr,  'Distance (km)', _T.blue),
          const SizedBox(width: 10),
          _statCard(2, _calsStr,  'Calories',      _T.green),
        ],
      ),
    );
  }

  Widget _statCard(int idx, String val, String label, Color color) {
    final active = _activeCard == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchCard(idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.1) : _T.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? color : _T.divider,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val, style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: active ? color : _T.hi,
              )),
              const SizedBox(height: 4),
              Text(label, style: GoogleFonts.inter(
                fontSize: 10, color: _T.mid,
              )),
            ],
          ),
        ),
      ),
    );
  }

  // ── CHART SECTION ──
  Widget _chartSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: _T.card,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_chartTitle, style: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w700, color: _T.hi,
          )),
          const SizedBox(height: 4),
          Text(_statSubtitle, style: GoogleFonts.inter(
            fontSize: 12, color: _T.mid,
          )),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LayoutBuilder(
              builder: (context, constraints) => CustomPaint(
                size: Size(constraints.maxWidth, 180),
                painter: _BarChartPainter(
                  bars: _bars,
                  xLabels: _xLabels,
                  color: _chartColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LIST SECTION ──
  Widget _listSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _listToggleBtn(_listLabel, 0)),
              const SizedBox(width: 10),
              Expanded(child: _listToggleBtn('Activity', 1)),
            ],
          ),
          const SizedBox(height: 20),
          if (_listTab == 0)
            ..._listItems.map((item) => _listItem(item['val']!, item['sub']!, item['id']!, isToday: item['isToday'] == 'true'))
          else
            if (_listItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text('No activity data yet',
                      style: GoogleFonts.inter(fontSize: 14, color: _T.mid)),
                ),
              )
            else
              ..._listItems.map((item) => _listItem(item['val']!, item['sub']!, item['id']!, isToday: item['isToday'] == 'true'))
        ],
      ),
    );
  }

  Widget _listToggleBtn(String label, int idx) {
    final active = _listTab == idx;
    return GestureDetector(
      onTap: () => setState(() => _listTab = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: active ? _T.accent : _T.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? _T.accent : _T.divider),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: active ? Colors.white : _T.mid,
          )),
        ),
      ),
    );
  }

  Widget _listItem(String val, String sub, String id, {bool isToday = false}) {
    return GestureDetector(
      onTap: () async {
        if (id.isEmpty) return;
        HapticFeedback.lightImpact();
        // 5. GET /api/activity/session/{id}
        try {
           final sessionDetails = await ref.read(trackingRepositoryProvider).getSessionById(id);
           if (!mounted) return;
           showDialog(context: context, builder: (_) => AlertDialog(
             backgroundColor: _T.card,
             title: Text('Session Details', style: GoogleFonts.inter(color: _T.hi)),
             content: Text('Type: ${sessionDetails['data']?['type'] ?? 'Unknown'}\nSteps: ${sessionDetails['data']?['steps'] ?? 0}\nDuration: ${sessionDetails['data']?['duration_seconds'] ?? 0}s', style: GoogleFonts.inter(color: _T.mid)),
             actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: GoogleFonts.inter(color: _T.accent)))],
           ));
        } catch(e) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot fetch session details $e')));
        }
      },
      child: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday ? _T.accent.withOpacity(0.2) : _chartColor.withOpacity(0.1),
              border: Border.all(color: isToday ? _T.accent : _chartColor.withOpacity(0.4), width: isToday ? 1.5 : 1.0),
            ),
            child: Icon(
              _activeCard == 1
                  ? Icons.straighten_rounded
                  : _activeCard == 2
                      ? Icons.local_fire_department_rounded
                      : Icons.directions_walk_rounded,
              color: isToday ? _T.accent : _chartColor, size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val, style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700, color: _T.hi,
              )),
              const SizedBox(height: 3),
              Text(sub, style: GoogleFonts.inter(
                fontSize: 12, color: isToday ? _T.accent : _T.mid, fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
              )),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  BAR CHART PAINTER
// ══════════════════════════════════════════════════════════
class _BarChartPainter extends CustomPainter {
  final List<double> bars;
  final List<String> xLabels;
  final Color color;
  _BarChartPainter({required this.bars, required this.xLabels, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    const labelH  = 24.0;
    const yLabelW = 36.0;
    final chartW  = size.width - yLabelW;
    final chartH  = size.height - labelH;

    final maxVal = bars.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;

    const gridCount = 4;
    final gridPaint = Paint()
      ..color = const Color(0xFF252525)
      ..strokeWidth = 1;

    final yStyle = TextStyle(fontSize: 9, color: const Color(0xFF5A5A5A), fontFamily: 'Inter');

    for (int i = 0; i <= gridCount; i++) {
      final y = chartH - (chartH * i / gridCount);
      canvas.drawLine(Offset(yLabelW, y), Offset(size.width, y), gridPaint);
      final val = (maxVal * i / gridCount);
      final label = val >= 1000
          ? '${(val / 1000).toStringAsFixed(1)}k'
          : val >= 1
              ? val.toStringAsFixed(val % 1 == 0 ? 0 : 1)
              : val.toStringAsFixed(2);
      final tp = TextPainter(
        text: TextSpan(text: label, style: yStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final n     = bars.length;
    final slotW = chartW / n;
    final barW  = (slotW * 0.55).clamp(4.0, 20.0);

    for (int i = 0; i < n; i++) {
      if (bars[i] == 0) continue;
      final barH = (bars[i] / maxVal) * chartH;
      final x    = yLabelW + slotW * i + (slotW - barW) / 2;
      final top  = chartH - barH;
      final rect = Rect.fromLTWH(x, top, barW, barH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(5)),
        Paint()
          ..shader = LinearGradient(
            colors: [color, color.withOpacity(0.35)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(rect),
      );
    }

    final xStyle = TextStyle(fontSize: 9, color: const Color(0xFF5A5A5A), fontFamily: 'Inter');
    final step   = (n - 1) / (xLabels.length - 1);
    for (int i = 0; i < xLabels.length; i++) {
      final barIndex = (i * step).round().clamp(0, n - 1);
      final x = yLabelW + slotW * barIndex + slotW / 2;
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: xStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 6));
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter o) =>
      o.bars != bars || o.xLabels != xLabels || o.color != color;
}
