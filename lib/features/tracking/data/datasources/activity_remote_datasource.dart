import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // GET /activity/stats/daily?date=YYYY-MM-DD → hourly breakdown
  // Response: { date, hours: [{hour, label, steps, calories, distance, hasActivity}],
  //             totalSteps, totalCalories, totalDistance, peakHour }
  Future<Map<String, dynamic>> getDailyStats({String? date}) async {
    final localDate = date ?? DateTime.now().toIso8601String().split('T')[0];
    debugPrint('📊 Fetching daily stats for: $localDate');
    try {
      final response = await _dio.get(
        ApiConstants.activityDailyStats,
        queryParameters: {'date': localDate},
      );
      final parsed = _parseResponse(response.data);
      debugPrint('📊 Daily stats response: $parsed');
      return parsed;
    } catch (e) {
      debugPrint('❌ Daily stats API failed: $e');
      rethrow;
    }
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
      final startData = {
        'startTime': DateTime.now().toIso8601String(),
        'baselineSteps': baselineSteps,
      };
      
      print('\n🚀 REALTIME START SESSION JSON:\n${jsonEncode(startData)}\n');

      final response = await _dio.post(
        ApiConstants.activitySessionStart,
        data: startData,
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
      final endTime = DateTime.now().toIso8601String();
      final stopData = {
        'sessionId': sessionId,
        'endTime': endTime,
        'finalSteps': finalSteps,
        'finalCalories': finalCalories,
        'finalDistance': finalDistance,
      };
      
      try {
        final parsedTime = DateTime.parse(endTime);
        final hourBucket = '${parsedTime.hour}:00 - ${parsedTime.hour + 1}:00';
        debugPrint('');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('🔬 STOP SESSION DEBUG (Datasource):');
        debugPrint('   🛑 Stopping session: $sessionId');
        debugPrint('   📊 Final steps sent: $finalSteps');
        debugPrint('   ⏰ endTime sent: $endTime');
        debugPrint('   🪣 Target bucket of endTime: $hourBucket');
        debugPrint('   📋 Full Stop payload: ${jsonEncode(stopData)}');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('');
      } catch (_) {}

      final response = await _dio.patch(
        ApiConstants.activitySessionStop,
        data: stopData,
      );
    return _parseResponse(response.data);
  }

  // POST /activity/sync → send live steps to server
  Future<void> syncSteps({
    required String sessionId,
    required int steps,
    required int calories,
    required double distance,
    String? customTimestamp,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stepTime = customTimestamp ?? prefs.getString('last_step_timestamp') ?? DateTime.now().toIso8601String();
    final payload = {
      'sessionId': sessionId,
      'steps': steps,
      'calories': calories,
      'distance': distance,
      'timestamp': stepTime,
    };
    
    // ═══ HEAVY DEBUG: SYNC STEPS ═══
    try {
      final parsedTime = DateTime.parse(stepTime);
      final hourBucket = '${parsedTime.hour}:00 - ${parsedTime.hour + 1}:00';
      debugPrint('');
      debugPrint('═══════════════════════════════════════════');
      debugPrint('🔬 SYNC DEBUG (foreground datasource):');
      debugPrint('   📤 Sending $steps steps to backend');
      debugPrint('   ⏰ Timestamp: $stepTime');
      debugPrint('   🪣 Hour bucket: $hourBucket');
      debugPrint('   🔑 Session: $sessionId');
      debugPrint('   📋 Full payload: ${jsonEncode(payload)}');
      debugPrint('═══════════════════════════════════════════');
      debugPrint('');
    } catch (_) {}
    
    await _dio.post(
      ApiConstants.activitySync,
      data: payload,
    );
  }

  /// Replay local hourly step buckets to the backend as timestamped cumulative syncs
  Future<void> replayHourlyBuckets(String sessionId) async {
    if (sessionId.isEmpty || sessionId.startsWith('local_')) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    int cumulativeSteps = 0;
    int replayedCount = 0;

    debugPrint('');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🔄 STARTING HOURLY REPLAY FOR SESSION: $sessionId');

    for (int h = 0; h <= now.hour; h++) {
      final bucketKey = 'hourly_steps_${sessionId}_$h';
      final hourSteps = prefs.getInt(bucketKey) ?? 0;
      if (hourSteps > 0) {
        cumulativeSteps += hourSteps;
        final calories = (cumulativeSteps * 0.045).round();
        final distance = double.parse((cumulativeSteps * 0.000762).toStringAsFixed(3));
        final hourPad = h.toString().padLeft(2, '0');
        final customTimestamp = '${todayStr}T$hourPad:59:59.000';

        debugPrint('   👉 Replaying Hour $h ($hourSteps steps -> cumulative $cumulativeSteps) @ $customTimestamp');

        try {
          await syncSteps(
            sessionId: sessionId,
            steps: cumulativeSteps,
            calories: calories,
            distance: distance,
            customTimestamp: customTimestamp,
          );
          replayedCount++;
        } catch (e) {
          debugPrint('   ⚠️ Replay failed for hour $h: $e');
        }
      } else {
        debugPrint('   ⏭️ Replay skip hour $h: $bucketKey has 0 steps');
      }
    }

    debugPrint('✅ HOURLY REPLAY COMPLETE: Replayed $replayedCount buckets (Total cumulative: $cumulativeSteps steps)');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('');
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

  // GET /activity/progress → streak, phase, last7Days
  Future<Map<String, dynamic>> getActivityProgress() async {
    final response = await _dio.get(ApiConstants.activityProgress);
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
