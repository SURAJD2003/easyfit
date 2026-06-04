import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/api_client.dart';
import '../../../../core/api_constants.dart';
import '../../../../models/api_result.dart';
import '../models/app_notification.dart';

class NotificationService {
  final Dio _dio = ApiClient().dio;

  Future<ApiResult<List<AppNotification>>> getNotifications() async {
    try {
      final response = await _dio.get(
        ApiConstants.notifications,
        options: Options(headers: {'Accept': 'text/plain'}),
      );

      final responseData = _decodeResponse(response.data);
      if (responseData is! Map<String, dynamic>) {
        return ApiResult.failure(
          ApiError(
            statusCode: response.statusCode,
            message: 'Invalid announcements response',
          ),
        );
      }

      final rawNotifications = responseData['notifications'];
      final notifications = rawNotifications is List
          ? rawNotifications
                .whereType<Map<String, dynamic>>()
                .map(AppNotification.fromJson)
                .toList()
          : <AppNotification>[];

      return ApiResult.success(notifications);
    } on DioException catch (error) {
      return ApiResult.failure(_handleDioError(error));
    } catch (error) {
      return ApiResult.failure(ApiError(message: 'Unexpected error: $error'));
    }
  }

  dynamic _decodeResponse(dynamic data) {
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  ApiError _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = _decodeResponse(error.response?.data);

    if (data is Map<String, dynamic>) {
      return ApiError(
        statusCode: statusCode,
        message:
            data['detail']?.toString() ??
            data['title']?.toString() ??
            data['message']?.toString() ??
            'Failed to fetch announcements',
      );
    }

    return ApiError(
      statusCode: statusCode,
      message: statusCode == 401
          ? 'Session expired. Please sign in again.'
          : 'Failed to fetch announcements',
    );
  }
}
