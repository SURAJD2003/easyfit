import '../../domain/repositories/tracking_repository.dart';
import '../datasources/activity_remote_datasource.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final ActivityRemoteDatasource remoteDatasource;

  TrackingRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Map<String, dynamic>> getTodayActivity() {
    return remoteDatasource.getTodayActivity();
  }

  @override
  Future<Map<String, dynamic>> getDailyStats({String? date}) {
    return remoteDatasource.getDailyStats(date: date);
  }

  @override
  Future<Map<String, dynamic>> getWeeklyStats({String? startDate, String? endDate}) {
    return remoteDatasource.getWeeklyStats(startDate: startDate, endDate: endDate);
  }

  @override
  Future<Map<String, dynamic>> getMonthlyStats({String? startDate, String? endDate}) {
    return remoteDatasource.getMonthlyStats(startDate: startDate, endDate: endDate);
  }

  @override
  Future<Map<String, dynamic>> getActivityHistory() {
    return remoteDatasource.getActivityHistory();
  }

  @override
  Future<Map<String, dynamic>> startSession(int baselineSteps) {
    return remoteDatasource.startSession(baselineSteps);
  }

  @override
  Future<Map<String, dynamic>> stopSession({
    required String sessionId,
    required int finalSteps,
    required int finalCalories,
    required double finalDistance,
  }) {
    return remoteDatasource.stopSession(
      sessionId: sessionId,
      finalSteps: finalSteps,
      finalCalories: finalCalories,
      finalDistance: finalDistance,
    );
  }

  @override
  Future<Map<String, dynamic>> getSessionById(String id) {
    return remoteDatasource.getSessionById(id);
  }

  @override
  Future<void> syncSteps({required String sessionId, required int steps, required int calories, required double distance}) {
    return remoteDatasource.syncSteps(sessionId: sessionId, steps: steps, calories: calories, distance: distance);
  }
}
