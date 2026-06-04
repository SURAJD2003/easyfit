abstract class RouteNames {
  // ─── USER ROUTES (unchanged) ──────────────────────────
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPass = '/forgot-password';
  static const dashboard = '/dashboard';
  static const you = '/you';
  static const stats = '/stats';
  static const tracking = '/tracking';
  static const history = '/history';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const notifications = '/notifications';
  static const subscription = '/subscription';
  static const approvalPending = '/approval-pending';

  // ─── ADMIN ROUTES ─────────────────────────────────────
  static const admin = '/admin';
  static const adminLogin = '/admin/login';
  static const adminDashboard =
      '/admin/home'; // ✅ changed from /admin/dashboard
  static const adminUsers = '/admin/users';
  static const adminSubscriptions = '/admin/subscriptions';
  static const adminNotifications = '/admin/notifications'; // ✅ NEW
  static const adminReports = '/admin/reports'; // ✅ NEW
}
