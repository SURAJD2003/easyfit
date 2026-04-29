import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/api_result.dart';
import '../models/auth/register_request.dart';
import '../models/auth/register_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/logout_request.dart';
import '../models/auth/logout_response.dart';
import '../models/auth/forgot_password_request.dart';
import '../models/auth/forgot_password_response.dart';

class AuthService {
  final _dio = ApiClient().dio;

  Future<ApiResult<RegisterResponse>> register(RegisterRequest req) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: req.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = RegisterResponse.fromJson(
            response.data as Map<String, dynamic>);

        if (data.token != null) {
          ApiClient().setToken(data.token!);
        }

        return ApiResult.success(data);
      }

      return ApiResult.failure(
        ApiError(
          message: 'Unexpected error',
          statusCode: response.statusCode,
        ),
      );
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ApiError(message: 'Unexpected error: $e'),
      );
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConstants.userProfile);
      
      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map<String, dynamic>) {
          return ApiResult.success(responseData);
        } else {
             return ApiResult.success(responseData as Map<String, dynamic>);
        }
      }
      return ApiResult.failure(ApiError(message: 'Failed to fetch profile'));
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(ApiError(message: 'Unexpected error: $e'));
    }
  }

  ApiError _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      return ApiError.fromJson(data, statusCode: statusCode);
    }

    switch (statusCode) {
      case 400:
        return ApiError(
          message: 'Invalid input. Please check your details.',
          statusCode: 400,
        );
      case 401:
        return ApiError(
          message: 'Invalid email or password.',
          statusCode: 401,
        );
      case 409:
        return ApiError(
          message: 'Email already registered.',
          statusCode: 409,
        );
      case 500:
        return ApiError(
          message: 'Server error. Please try again later.',
          statusCode: 500,
        );
      default:
        return ApiError(
          message: e.message ?? 'Network error',
          statusCode: statusCode,
        );
    }
  }

  Future<ApiResult<LoginResponse>> login(LoginRequest req) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: req.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = LoginResponse.fromJson(
            response.data as Map<String, dynamic>);

        if (data.token != null) {
          ApiClient().setToken(data.token!);
        }

        return ApiResult.success(data);
      }

      return ApiResult.failure(
        ApiError(
          message: 'Unexpected error',
          statusCode: response.statusCode,
        ),
      );
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ApiError(message: 'Unexpected error: $e'),
      );
    }
  }

  Future<ApiResult<LogoutResponse>> logout(LogoutRequest req) async {
    try {
      final response = await _dio.post(
        ApiConstants.logout,
        data: req.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = LogoutResponse.fromJson(
            response.data as Map<String, dynamic>);

        ApiClient().clearToken();

        return ApiResult.success(data);
      }

      return ApiResult.failure(
        ApiError(
          message: 'Unexpected error',
          statusCode: response.statusCode,
        ),
      );
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ApiError(message: 'Unexpected error: $e'),
      );
    }
  }

  Future<ApiResult<ForgotPasswordResponse>> forgotPassword(ForgotPasswordRequest req) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: req.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ForgotPasswordResponse.fromJson(
            response.data as Map<String, dynamic>);

        return ApiResult.success(data);
      }

      return ApiResult.failure(
        ApiError(
          message: 'Unexpected error',
          statusCode: response.statusCode,
        ),
      );
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ApiError(message: 'Unexpected error: $e'),
      );
    }
  }
}