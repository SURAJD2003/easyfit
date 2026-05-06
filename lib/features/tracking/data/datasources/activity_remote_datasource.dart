import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api_client.dart';
import '../../../../core/api_constants.dart';

class ActivityRemoteDatasource {
  final Dio _dio = ApiClient().dio;

  /// The server returns text/plain, so response.data might be a String.
  /// This helper safely decodes it into a Map.
  Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  List<dynamic> _parseListResponse(dynamic data) {
    if (data is List) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) return decoded;
      } catch (_) {}
    }
    return [];
  }

  // GET /activity/today → dashboard hero card
  // Send client's local date to avoid timezone mismatch
  Future<Map<String, dynamic>> getTodayActivity() async {
    final localDate = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final response = await _dio.get(
      ApiConstants.activityToday,
      queryParameters: {'date': localDate},
    );
    return _parseResponse(response.data);
  }

  // GET /activity/stats/weekly?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
  Future<Map<String, dynamic>> getWeeklyStats({String? startDate, String? endDate}) async {
    final Map<String, dynamic> params = {};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    final response = await _dio.get(
      ApiConstants.activityWeeklyStats,
      queryParameters: params.isNotEmpty ? params : null,
    );
    return _parseResponse(response.data);
  }

  // POST /activity/session/start → "Continue Your Journey" tapped
  // Backend handles orphan sessions automatically:
  //   201 = new session created
  //   200 = resumed existing session (still fresh)
  Future<Map<String, dynamic>> startSession(int baselineSteps) async {
    final response = await _dio.post(
      ApiConstants.activitySessionStart,
      data: {
        'startTime': DateTime.now().toIso8601String(),
        'baselineSteps': baselineSteps,
      },
    );
    final parsed = _parseResponse(response.data);
    // Include HTTP status so caller knows if session was resumed (200) or new (201)
    parsed['_httpStatus'] = response.statusCode;
    return parsed;
  }

  // PATCH /activity/session/stop → session ended
  Future<Map<String, dynamic>> stopSession({
    required String sessionId,
    required int finalSteps,
    required int finalCalories,
    required double finalDistance,
  }) async {
    final response = await _dio.patch(
      ApiConstants.activitySessionStop,
      data: {
        'sessionId': sessionId,
        'endTime': DateTime.now().toIso8601String(),
        'finalSteps': finalSteps,
        'finalCalories': finalCalories,
        'finalDistance': finalDistance,
      },
    );
    return _parseResponse(response.data);
  }

  // POST /activity/sync → send live steps to server
  Future<void> syncSteps({
    required String sessionId,
    required int steps,
    required int calories,
    required double distance,
  }) async {
    await _dio.post(
      ApiConstants.activitySync,
      data: {
        'sessionId': sessionId,
        'steps': steps,
        'calories': calories,
        'distance': distance,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // GET /activity/stats/monthly?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
  Future<Map<String, dynamic>> getMonthlyStats({String? startDate, String? endDate}) async {
    final Map<String, dynamic> params = {};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    final response = await _dio.get(
      ApiConstants.activityMonthlyStats,
      queryParameters: params.isNotEmpty ? params : null,
    );
    return _parseResponse(response.data);
  }

  // GET /activity/history
  Future<Map<String, dynamic>> getActivityHistory() async {
    final response = await _dio.get(ApiConstants.activityHistory);
    return _parseResponse(response.data);
  }

  // GET /activity/session/{id}
  Future<Map<String, dynamic>> getSessionById(String id) async {
    final response = await _dio.get(ApiConstants.activitySessionById(id));
    return _parseResponse(response.data);
  }

  // GET /reports/daily?date=YYYY-MM-DD
  Future<Map<String, dynamic>> getDailyReport(String date) async {
    final response = await _dio.get(
      ApiConstants.reportsDaily,
      queryParameters: {'date': date},
      options: Options(headers: {'Accept': 'text/plain'}),
    );
    return _parseResponse(response.data);
  }

  // GET /reports/weekly?week=YYYY-MM-DD
  Future<Map<String, dynamic>> getWeeklyReport(String week) async {
    final response = await _dio.get(
      ApiConstants.reportsWeekly,
      queryParameters: {'week': week},
      options: Options(headers: {'Accept': 'text/plain'}),
    );
    return _parseResponse(response.data);
  }

  // GET /reports/monthly?month=YYYY-MM
  Future<Map<String, dynamic>> getMonthlyReport(String month) async {
    final response = await _dio.get(
      ApiConstants.reportsMonthly,
      queryParameters: {'month': month},
      options: Options(headers: {'Accept': 'text/plain'}),
    );
    return _parseResponse(response.data);
  }

  // GET /reports/share/{type} → type = daily | weekly | monthly
  Future<Map<String, dynamic>> shareReport(String type) async {
    final response = await _dio.get(
      ApiConstants.reportsShare(type),
      options: Options(headers: {'Accept': 'text/plain'}),
    );
    return _parseResponse(response.data);
  }
}