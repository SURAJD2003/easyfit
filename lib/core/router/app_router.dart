import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/tracking/presentation/screens/dashboard_screen.dart';
import '../../features/tracking/presentation/screens/you_screen.dart';
import '../../features/tracking/presentation/screens/stats_screen.dart';
import '../../features/admin/presentation/screens/index.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../../features/auth/presentation/screens/approval_pending_screen.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: true,
  routes: [
    // ─── USER ROUTES (unchanged) ─────────────────────────
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: RouteNames.register,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const RegisterScreen(),
        transitionsBuilder: (context, animation, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: RouteNames.forgotPass,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RouteNames.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: RouteNames.you,
      builder: (context, state) => const YouScreen(),
    ),
    GoRoute(
      path: RouteNames.stats,
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: RouteNames.subscription,
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: RouteNames.approvalPending,
      builder: (context, state) => const ApprovalPendingScreen(),
    ),

    // ─── ADMIN ROUTES ─────────────────────────────────────
    GoRoute(
      path: RouteNames.adminLogin,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const AdminLoginScreen(),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: RouteNames.adminDashboard,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const AdminMainScreen(),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: RouteNames.adminUsers,
      builder: (context, state) => const AdminUsersScreen(),
    ),
    GoRoute(
      path: '${RouteNames.adminUsers}/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return AdminUserDetailScreen(userId: userId);
      },
    ),
    GoRoute(
      path: RouteNames.adminSubscriptions,
      builder: (context, state) => const AdminSubscriptionsScreen(),
    ),
    // ✅ NEW — these were missing
    GoRoute(
      path: RouteNames.adminNotifications,
      builder: (context, state) => const AdminNotificationsScreen(),
    ),
    GoRoute(
      path: RouteNames.adminReports,
      builder: (context, state) => const AdminReportsScreen(),
    ),
  ],
);