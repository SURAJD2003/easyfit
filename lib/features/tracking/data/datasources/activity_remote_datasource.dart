import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
        
        // ═══ CONSISTENCY AUDIT: Compare synced total vs finalSteps ═══
        final prefs = await SharedPreferences.getInstance();
        await prefs.reload();
        int totalSyncedToBackend = 0;
        final List<String> syncedBreakdown = [];
        for (int h = 0; h < 24; h++) {
          final syncedKey = 'synced_hourly_steps_${sessionId}_$h';
          final synced = prefs.getInt(syncedKey) ?? 0;
          if (synced > 0) {
            totalSyncedToBackend += synced;
            syncedBreakdown.add('Hour $h: $synced');
          }
        }
        final match = totalSyncedToBackend == finalSteps ? '✅ MATCH' : '⚠️ MISMATCH';
        
        debugPrint('');
        debugPrint('═══════════════════════════════════════════');
        debugPrint('🔬 STOP SESSION DEBUG (Datasource):');
        debugPrint('   🛑 Stopping session: $sessionId');
        debugPrint('   📊 Final steps sent to /stop: $finalSteps');
        debugPrint('   📊 Total synced via /sync:    $totalSyncedToBackend');
        debugPrint('   $match');
        if (syncedBreakdown.isNotEmpty) {
          debugPrint('   📦 Synced breakdown: ${syncedBreakdown.join(', ')}');
        }
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

  static bool _isSyncing = false;

  // POST /activity/sync → send hourly delta buckets to server as an array
  Future<void> syncHourlyBuckets(String sessionId) async {
    if (sessionId.isEmpty || sessionId.startsWith('local_')) return;
    
    if (_isSyncing) {
      debugPrint('⏭️ FG hourly skipped: sync already in progress');
      return;
    }
    _isSyncing = true;

    try {
    
    // If the background service is running, IT owns syncing the hourly buckets.
    // If we sync from the foreground at the exact same time, we'll double-sync the delta
    // because both read the old `alreadySynced` value from SharedPreferences before either writes to it.
    final service = FlutterBackgroundService();
    final isBackgroundRunning = await service.isRunning();
    if (isBackgroundRunning) {
      debugPrint('⏭️ FG hourly skipped: background service owns hourly buckets (session=$sessionId)');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    
    // Cross-isolate lock wait
    bool isBgSyncing = prefs.getBool('is_bg_syncing') ?? false;
    int waitCount = 0;
    while (isBgSyncing && waitCount < 10) {
      debugPrint('⏳ FG waiting for BG sync to finish (cross-isolate lock)...');
      await Future.delayed(const Duration(milliseconds: 500));
      await prefs.reload();
      isBgSyncing = prefs.getBool('is_bg_syncing') ?? false;
      waitCount++;
    }

    final now = DateTime.now();

    // Build hourlyData array with DELTAS (new steps since last successful sync)
    final List<Map<String, dynamic>> hourlyData = [];

    for (int h = 0; h <= now.hour; h++) {
      final bucketKey = 'hourly_steps_${sessionId}_$h';
      final syncedKey = 'synced_hourly_steps_${sessionId}_$h';
      final totalSteps = prefs.getInt(bucketKey) ?? 0;
      final alreadySynced = prefs.getInt(syncedKey) ?? 0;
      final delta = totalSteps - alreadySynced;

      if (delta > 0) {
        final deltaCals = (delta * 0.045).round();
        final deltaDist = double.parse((delta * 0.000762).toStringAsFixed(3));
        hourlyData.add({
          'hour': h,
          'steps': delta,
          'calories': deltaCals,
          'distance': deltaDist,
        });
        debugPrint('   📦 Hour $h: delta=$delta (total=$totalSteps, synced=$alreadySynced)');
      }
    }

    if (hourlyData.isEmpty) {
      debugPrint('⏭️ syncHourlyBuckets: No new deltas to send');
      return;
    }

    final payload = {
      'sessionId': sessionId,
      'hourlyData': hourlyData,
    };

    debugPrint('');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('📤 SYNC HOURLY BUCKETS (Array):');
    debugPrint('   🔑 Session: $sessionId');
    debugPrint('   📦 Buckets: ${hourlyData.length}');
    debugPrint('   📋 Payload: ${jsonEncode(payload)}');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('');

    await _dio.post(
      ApiConstants.activitySync,
      data: payload,
    );

    // SUCCESS — mark these deltas as synced so we don't send them again
    for (final bucket in hourlyData) {
      final h = bucket['hour'] as int;
      final syncedKey = 'synced_hourly_steps_${sessionId}_$h';
      final bucketKey = 'hourly_steps_${sessionId}_$h';
      final currentTotal = prefs.getInt(bucketKey) ?? 0;
      await prefs.setInt(syncedKey, currentTotal);
    }

    debugPrint('✅ syncHourlyBuckets: Sent ${hourlyData.length} buckets successfully');
    } finally {
      _isSyncing = false;
    }
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
