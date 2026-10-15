import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api_client.dart';
import '../../../../core/api_constants.dart';
import '../../../../models/api_result.dart';
import '../models/app_notification.dart';

class NotificationService {
  final Dio _dio = ApiClient().dio;

  Future<ApiResult<List<AppNotification>>> getNotifications() async {
    try {
      // Ensure token is attached if available in storage
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('admin_token');
      if (token != null && token.isNotEmpty) {
        ApiClient().setToken(token);
      }

      final response = await _dio.get(
        ApiConstants.notifications,
        options: Options(headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        }),
      );

      final responseData = _decodeResponse(response.data);

      List<dynamic>? rawList;
      if (responseData is List) {
        rawList = responseData;
      } else if (responseData is Map<String, dynamic>) {
        rawList = responseData['notifications'] ??
            responseData['Notifications'] ??
            responseData['data'] ??
            responseData['Data'] ??
            responseData['items'] ??
            responseData['Items'] ??
            responseData['result'];
      }

      final notifications = rawList != null
          ? rawList
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

  Future<ApiResult<void>> markAsRead(String id) async {
    try {
      await _dio.post('/notifications/$id/read');
      return ApiResult.success(null);
    } on DioException catch (error) {
      return ApiResult.failure(_handleDioError(error));
    } catch (error) {
      return ApiResult.failure(ApiError(message: '$error'));
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
            data['error']?.toString() ??
            'Failed to fetch announcements',
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return ApiError(
        statusCode: statusCode,
        message: 'Network connection issue. Please check your internet.',
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
