class AnalyticsEntity {
  final int totalUsers;
  final int activeUsers;
  final int totalSessions;
  final double totalRevenue;
  final double avgDailySteps;
  final int totalSubscriptions;
  final int freeUsers;
  final int premiumUsers;

  const AnalyticsEntity({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalSessions,
    required this.totalRevenue,
    required this.avgDailySteps,
    required this.totalSubscriptions,
    required this.freeUsers,
    required this.premiumUsers,
  });
}