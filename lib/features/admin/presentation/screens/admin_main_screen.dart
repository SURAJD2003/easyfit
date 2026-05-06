import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easyfit_clinics/core/router/route_names.dart';
import '../providers/admin_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_subscriptions_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_reports_screen.dart';

class AdminMainScreen extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  static const Color _accent = Color(0xFFFF6B00);
  static const Color _bg = Color(0xFF0F0F0F);
  static const Color _cardColor = Color(0xFF1A1A1A);

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminUsersScreen(),
    AdminSubscriptionsScreen(),
    AdminNotificationsScreen(),
    AdminReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final adminName = provider.authState.adminName ?? 'Admin';
    final adminEmail = provider.authState.adminEmail ?? 'admin@easyfit.com';

    return Scaffold(
      key: AdminMainScreen.scaffoldKey,
      backgroundColor: _bg,
      drawer: Drawer(
        backgroundColor: _bg,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: _cardColor,
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _accent.withOpacity(0.1),
                    child: const Icon(Icons.admin_panel_settings, color: _accent, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          adminEmail,
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.white70),
              title: const Text('My Profile', style: TextStyle(color: Colors.white70)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white70),
              title: const Text('Settings', style: TextStyle(color: Colors.white70)),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                // ✅ Close drawer first
                Navigator.pop(context);
                await provider.logout();
                if (mounted) {
                  context.go(RouteNames.adminLogin);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: Builder(
        builder: (context) => IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.grid_view_rounded,
              label: 'Dashboard',
              index: 0,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
            _NavItem(
              icon: Icons.group_outlined,
              label: 'Users',
              index: 1,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
            _NavItem(
              icon: Icons.credit_card_outlined,
              label: 'Subscriptions',
              index: 2,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
            _NavItem(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              index: 3,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
            _NavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Reports',
              index: 4,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color _accent = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? _accent.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? _accent : Colors.white38,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? _accent : Colors.white38,
                fontSize: 11,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}