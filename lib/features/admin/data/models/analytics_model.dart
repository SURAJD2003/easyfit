import '../../domain/entities/analytics_entity.dart';

class AnalyticsModel extends AnalyticsEntity {
  const AnalyticsModel({
    required super.totalUsers,
    required super.activeUsers,
    required super.totalSessions,
    required super.totalRevenue,
    required super.avgDailySteps,
    required super.totalSubscriptions,
    required super.freeUsers,
    required super.premiumUsers,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    // subscriptionBreakdown: { free: n, premium: n }
    final breakdown = json['subscriptionBreakdown'] as Map<String, dynamic>? ?? {};

    return AnalyticsModel(
      totalUsers: _toInt(json['totalUsers']),
      activeUsers: _toInt(json['activeUsers']),
      totalSessions: _toInt(json['totalSessions']),
      totalRevenue: _toDouble(json['totalRevenue']),
      avgDailySteps: _toDouble(json['avgDailySteps']),
      totalSubscriptions: _toInt(breakdown['free']) + _toInt(breakdown['premium']),
      freeUsers: _toInt(breakdown['free']),
      premiumUsers: _toInt(breakdown['premium']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}