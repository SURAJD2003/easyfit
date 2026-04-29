class ApiConstants {
  static const String baseUrl = 'https://parkmitra.com/api';

  // ── Auth ─────────────────────────────────────────────
  static const String register       = '/auth/register';
  static const String login          = '/auth/login';
  static const String logout         = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String refreshToken   = '/auth/refresh-token';

  // ── User ──────────────────────────────────────────────
  static const String userProfile    = '/user/profile';

  // ── Dashboard ─────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String habits    = '/habits';

  // ── Activity & Step Tracking ──────────────────────────
  static const String activityToday        = '/activity/today';
  static const String activityWeeklyStats  = '/activity/stats/weekly';
  static const String activityMonthlyStats = '/activity/stats/monthly';
  static const String activityHistory      = '/activity/history';
  static const String activitySessionStart = '/activity/session/start';
  static const String activitySessionStop  = '/activity/session/stop';
  static const String activitySync         = '/activity/sync';

  static String activitySessionById(String id) => '/activity/session/$id';

  // ── Reports (MIS) ─────────────────────────────────────
  static const String reportsDaily   = '/reports/daily';
  static const String reportsWeekly  = '/reports/weekly';
  static const String reportsMonthly = '/reports/monthly';
  static String reportsShare(String type) => '/reports/share/$type';
}