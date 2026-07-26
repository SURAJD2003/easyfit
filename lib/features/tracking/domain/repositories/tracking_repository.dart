abstract class TrackingRepository {
  Future<Map<String, dynamic>> getTodayActivity();
  Future<Map<String, dynamic>> getDailyStats({String? date});
  Future<Map<String, dynamic>> getWeeklyStats({String? startDate, String? endDate});
  Future<Map<String, dynamic>> getMonthlyStats({String? startDate, String? endDate});
  Future<Map<String, dynamic>> getActivityHistory();
  
  Future<Map<String, dynamic>> startSession(int baselineSteps);
  Future<Map<String, dynamic>> stopSession({
    required String sessionId,
    required int finalSteps,
    required int finalCalories,
    required double finalDistance,
  });
  Future<Map<String, dynamic>> getSessionById(String id);
  Future<void> syncSteps({required String sessionId, required int steps, required int calories, required double distance, String? customTimestamp});
  Future<void> replayHourlyBuckets(String sessionId);
  Future<Map<String, dynamic>> getActivityProgress();
}
