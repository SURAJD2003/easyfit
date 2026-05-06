import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () => AdminMainScreen.scaffoldKey.currentState?.openDrawer(),
                                              icon: const Icon(
                                                Icons.menu_rounded,
                                                color: _accent,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
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
                                  // Right: notification bell + hero image
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          const Icon(
                                            Icons.notifications_none_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          Positioned(
                                            right: -3,
                                            top: -4,
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: const BoxDecoration(
                                                color: _accent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  '3',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Hero fitness image with orange splash
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=400&q=80',
                                              width: 110,
                                              height: 130,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, e, s) =>
                                                  Container(
                                                width: 110,
                                                height: 130,
                                                color: const Color(0xFF1A1A1A),
                                                child: const Icon(
                                                  Icons.fitness_center,
                                                  color: _accent,
                                                  size: 36,
                                                ),
                                              ),
                                            ),
                                            // Orange splash overlay at bottom
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                    colors: [
                                                      _accent.withOpacity(0.7),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                                  const SizedBox(height: 10),
                                  // Row 3: Average Daily Steps (wide with footprints)
                                  _StepsCard(avgDailySteps: analytics.avgDailySteps),
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
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.06),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: _accent.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.bar_chart_rounded,
                                        color: _accent,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Keep it up!',
                                            style: TextStyle(
                                              color: _accent,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Your active users are growing. Keep engaging your community.',
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.trending_up_rounded,
                                      color: _accent,
                                      size: 32,
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

// ── Average Daily Steps card with footprint decoration ──────────────────────
class _StepsCard extends StatelessWidget {
  final double avgDailySteps;
  const _StepsCard({required this.avgDailySteps});

  static const Color _accent = Color(0xFFFF6B00);
  static const Color _cardColor = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: _accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Daily Steps',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  avgDailySteps.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Average steps across users',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Footprint decoration
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _FootprintDecoration(),
          ),
        ],
      ),
    );
  }
}

class _FootprintDecoration extends StatelessWidget {
  static const Color _accent = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 60,
      child: Stack(
        children: [
          // Left footprint (top)
          Positioned(
            left: 0,
            top: 0,
            child: Icon(
              Icons.directions_walk_rounded,
              color: _accent.withOpacity(0.35),
              size: 26,
            ),
          ),
          // Right footprint (bottom-right)
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.directions_walk_rounded,
              color: _accent.withOpacity(0.55),
              size: 26,
            ),
          ),
          // Dotted line between them
          Positioned(
            left: 12,
            top: 26,
            child: Container(
              width: 2,
              height: 10,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
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
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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