import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_names.dart';
import '../providers/admin_provider.dart';
import 'admin_main_screen.dart';
import '../widgets/report_grid_card.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _bg = Color(0xFF0F0F0F);
  static const Color _cardColor = Color(0xFF1A1A1A);

  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    if (_dateRange == null) return;
    final from = DateFormat('yyyy-MM-dd').format(_dateRange!.start);
    final to = DateFormat('yyyy-MM-dd').format(_dateRange!.end);
    context.read<AdminProvider>().fetchReports(from: from, to: to);
  }

  void _setQuickFilter(int days) {
    setState(() {
      _dateRange = DateTimeRange(
        start: DateTime.now().subtract(Duration(days: days)),
        end: DateTime.now(),
      );
    });
    _fetchData();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _accent,
              onPrimary: Colors.white,
              surface: _cardColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() => _dateRange = picked);
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (context, provider, _) {
            final state = provider.reportsState;

            return RefreshIndicator(
              color: _accent,
              backgroundColor: _cardColor,
              onRefresh: () async => _fetchData(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // ── HEADER ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Platform Reports',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Analyze your growth and activity',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => AdminMainScreen.scaffoldKey.currentState?.openDrawer(),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _accent.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.menu_rounded,
                                          color: _accent, size: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: _selectDateRange,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _accent.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _accent.withOpacity(0.2),
                                        ),
                                      ),
                                      child: const Icon(Icons.date_range_rounded,
                                          color: _accent, size: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // ── QUICK FILTERS ──
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _QuickFilterChip(
                                  label: 'Last 7 Days',
                                  onPressed: () => _setQuickFilter(7),
                                  isSelected: _isRangeOf(7),
                                ),
                                const SizedBox(width: 8),
                                _QuickFilterChip(
                                  label: 'Last 30 Days',
                                  onPressed: () => _setQuickFilter(30),
                                  isSelected: _isRangeOf(30),
                                ),
                                const SizedBox(width: 8),
                                _QuickFilterChip(
                                  label: 'Last 90 Days',
                                  onPressed: () => _setQuickFilter(90),
                                  isSelected: _isRangeOf(90),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // ── SELECTED RANGE INFO ──
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _accent.withOpacity(0.15),
                                  _accent.withOpacity(0.05)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _accent.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.analytics_outlined,
                                    color: _accent, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Range: ${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // ── GRID STATS ──
                  if (state.isLoading && state.report == null)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: _accent),
                      ),
                    )
                  else if (state.error != null && state.report == null)
                    SliverFillRemaining(
                      child: _ErrorView(message: state.error!, onRetry: _fetchData),
                    )
                  else if (state.report != null)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          ReportGridCard(
                            title: 'New Users',
                            value: '${state.report!.newUsers}',
                            icon: Icons.person_add_rounded,
                            color: const Color(0xFF3B82F6),
                            subtitle: 'Joinings in range',
                          ),
                          ReportGridCard(
                            title: 'Active Users',
                            value: '${state.report!.activeUsers}',
                            icon: Icons.bolt_rounded,
                            color: const Color(0xFF10B981),
                            subtitle: 'Daily active users',
                          ),
                          ReportGridCard(
                            title: 'Total Steps',
                            value: NumberFormat.compact()
                                .format(state.report!.totalSteps),
                            icon: Icons.directions_walk_rounded,
                            color: _accent,
                            subtitle: 'Activity volume',
                          ),
                          ReportGridCard(
                            title: 'Calories',
                            value: NumberFormat.compact()
                                .format(state.report!.totalCalories),
                            icon: Icons.local_fire_department_rounded,
                            color: const Color(0xFFEF4444),
                            subtitle: 'Burned energy',
                          ),
                        ],
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isRangeOf(int days) {
    if (_dateRange == null) return false;
    final diff = _dateRange!.end.difference(_dateRange!.start).inDays;
    return diff >= days - 1 && diff <= days + 1;
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const _QuickFilterChip({
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      backgroundColor: const Color(0xFF1A1A1A),
      selectedColor: const Color(0xFFFF6B00).withOpacity(0.2),
      checkmarkColor: const Color(0xFFFF6B00),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFFF6B00) : Colors.white60,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFFFF6B00) : Colors.white10,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isSessionExpired = message.toLowerCase().contains('session expired') ||
        message.toLowerCase().contains('log in again') ||
        message.toLowerCase().contains('unauthorized') ||
        message.toLowerCase().contains('401');

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white38, size: 44),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 20),
          if (isSessionExpired) ...[
            ElevatedButton.icon(
              onPressed: () async {
                await context.read<AdminProvider>().logout();
                if (context.mounted) {
                  context.go(RouteNames.adminLogin);
                }
              },
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text('Log In Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: Colors.white38)),
            ),
          ] else
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}