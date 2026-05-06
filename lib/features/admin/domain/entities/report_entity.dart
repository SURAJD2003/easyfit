class ReportEntity {
  final int totalUsers;
  final int activeUsers;
  final int totalSessions;
  final double totalRevenue;
  final double avgDailySteps;
  final int freeUsers;
  final int premiumUsers;
  final int newUsers;
  final int totalSteps;
  final int totalCalories;

  const ReportEntity({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalSessions,
    required this.totalRevenue,
    required this.avgDailySteps,
    required this.freeUsers,
    required this.premiumUsers,
    this.newUsers = 0,
    this.totalSteps = 0,
    this.totalCalories = 0,
  });
}