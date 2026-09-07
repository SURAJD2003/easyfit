import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../providers/admin_provider.dart';
import 'admin_main_screen.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/dashboard_subscription_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  static const Color _accent = Color(0xFFFF6B00);
  static const Color _bg = Color(0xFF0F0F0F);
  static const Color _cardColor = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AdminProvider>().fetchAnalytics();
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<AdminProvider>().fetchAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (context, provider, _) {
            final state = provider.analyticsState;
            final adminName = provider.authState.adminName ?? 'Admin';

            if (state.isLoading && state.analytics == null) {
              return const Center(
                child: CircularProgressIndicator(color: _accent),
              );
            }

            if (state.error != null && state.analytics == null) {
              return _ErrorView(
                message: state.error!,
                onRetry: () => provider.fetchAnalytics(),
              );
            }

            final analytics = state.analytics;
            if (analytics == null) return const SizedBox.shrink();

            return RefreshIndicator(
              color: _accent,
              backgroundColor: _cardColor,
              onRefresh: _onRefresh,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── TOP BAR ──────────────────────────────────
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: menu + title + welcome
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: IconButton(
                                                onPressed: () => AdminMainScreen.scaffoldKey.currentState?.openDrawer(),
                                                icon: const Icon(
                                                  Icons.menu_rounded,
                                                  color: _accent,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              'Dashboard',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Welcome back,',
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              adminName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 26,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              '💪',
                                              style: TextStyle(fontSize: 22),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── STAT CARDS GRID ───────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  // Row 1: Total Users | Active Users
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AdminStatCard(
                                          icon: Icons.group_rounded,
                                          title: 'Total Users',
                                          value: '${analytics.totalUsers}',
                                          subtitle: 'All registered users',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: AdminStatCard(
                                          icon: Icons.person_rounded,
                                          title: 'Active Users',
                                          value: '${analytics.activeUsers}',
                                          subtitle: 'Currently active users',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Row 2: Total Sessions | Total Revenue
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AdminStatCard(
                                          icon: Icons.fitness_center_rounded,
                                          title: 'Total Sessions',
                                          value: '${analytics.totalSessions}',
                                          subtitle: 'All workout sessions',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: AdminStatCard(
                                          icon: Icons.account_balance_wallet_rounded,
                                          title: 'Total Revenue',
                                          value: '₹${analytics.totalRevenue.toStringAsFixed(0)}',
                                          subtitle: 'All time revenue',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── SUBSCRIPTION BREAKDOWN ────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DashboardSubscriptionCard(analytics: analytics),
                            ),

                            const SizedBox(height: 12),

                            // ── KEEP IT UP CARD ───────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _accent.withOpacity(0.15),
                                      _accent.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: _accent.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: _accent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: _accent.withOpacity(0.3)),
                                      ),
                                      child: const Icon(
                                        Icons.auto_graph_rounded,
                                        color: _accent,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Keep it up!',
                                            style: TextStyle(
                                              color: _accent,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Your active users are growing. Keep engaging your community.',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



// ── Error view ────────────────────────────────────────────────────────────────
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white38, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ] else
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}