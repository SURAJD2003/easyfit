class ApiConstants {
  static const String baseUrl = 'https://api.theeasyfitclinics.com/api';
  static const String adminBaseUrl = 'https://api.theeasyfitclinics.com';

  // ── Auth ─────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String refreshToken = '/auth/refresh-token';

  // ── User ──────────────────────────────────────────────
  static const String userProfile    = '/user/profile';
  static const String deleteAccount  = '/user/account';

  // ── Dashboard ─────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String habits = '/habits';

  // ── Activity & Step Tracking ──────────────────────────
  static const String activityToday = '/activity/today';
  static const String activityDailyStats = '/activity/stats/daily'; // hourly breakdown
  static const String activityWeeklyStats = '/activity/stats/weekly';
  static const String activityMonthlyStats = '/activity/stats/monthly';
  static const String activityHistory = '/activity/history';
  static const String activitySessionStart = '/activity/session/start';
  static const String activitySessionStop = '/activity/session/stop';
  static const String activitySync = '/activity/sync';
  static const String activityProgress = '/activity/progress';

  static String activitySessionById(String id) => '/activity/session/$id';

  // ── Reports (MIS) ─────────────────────────────────────
  static const String reportsDaily = '/reports/daily';
  static const String reportsWeekly = '/reports/weekly';
  static const String reportsMonthly = '/reports/monthly';
  static String reportsShare(String type) => '/reports/share/$type';

  // ── Admin Panel ───────────────────────────────────────
  static const String adminLogin = '/admin/login';
  static const String adminProfile = '/admin/profile';
  static const String adminDashboardStats = '/admin/dashboard/stats';
  static const String adminUsers = '/api/admin/users';
  static const String adminSubscriptions = '/api/admin/subscriptions';
  static const String adminAnalytics = '/api/admin/analytics';
  static const String adminReportsOverview = '/api/admin/reports/overview';
  static const String adminNotificationsBroadcast = '/api/admin/notifications/broadcast';
  static const String adminNotificationsSegment = '/api/admin/notifications/segment';

  static String adminUserDetail(String userId) => '/api/admin/users/$userId';
  static String adminApproveSubscription(String subId) =>
      '/api/admin/subscriptions/$subId/approve';
  static String adminRejectSubscription(String subId) =>
      '/api/admin/subscriptions/$subId/reject';
  static String adminSubscriptionDetail(String subId) =>
      '/api/admin/subscriptions/$subId';
}
