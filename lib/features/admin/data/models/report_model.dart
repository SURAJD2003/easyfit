import '../../domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.totalUsers,
    required super.activeUsers,
    required super.totalSessions,
    required super.totalRevenue,
    required super.avgDailySteps,
    required super.freeUsers,
    required super.premiumUsers,
    super.newUsers,
    super.totalSteps,
    super.totalCalories,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      totalUsers: _toInt(json['totalUsers'] ?? json['newUsers']), // Fallback
      activeUsers: _toInt(json['activeUsers']),
      totalSessions: _toInt(json['totalSessions']),
      totalRevenue: _toDouble(json['totalRevenue']),
      avgDailySteps: _toDouble(json['avgDailySteps']),
      freeUsers: _toInt(json['freeUsers']),
      premiumUsers: _toInt(json['premiumUsers']),
      newUsers: _toInt(json['newUsers']),
      totalSteps: _toInt(json['totalSteps']),
      totalCalories: _toInt(json['totalCalories']),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}