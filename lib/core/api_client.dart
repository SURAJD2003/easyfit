import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  String? _token;
  String? get token => _token;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://uat-api.theeasyfitclinics.com/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && error.requestOptions.path != '/auth/refresh-token') {
          try {
            final prefs = await SharedPreferences.getInstance();
            final refreshToken = prefs.getString('auth_refresh_token');

            if (refreshToken != null && refreshToken.isNotEmpty) {
              final refreshDio = Dio(BaseOptions(
                baseUrl: 'https://uat-api.theeasyfitclinics.com/api',
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ));

              final response = await refreshDio.post(
                '/auth/refresh-token',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200) {
                var responseData = response.data;
                if (responseData is String) {
                  try {
                    responseData = jsonDecode(responseData);
                  } catch (_) {}
                }

                if (responseData is Map<String, dynamic> && responseData['token'] != null) {
                  final newToken = responseData['token'];
                  final newRefreshToken = responseData['refreshToken'];

                  _token = newToken;
                  await prefs.setString('auth_token', newToken);

                  if (newRefreshToken != null) {
                    await prefs.setString('auth_refresh_token', newRefreshToken);
                  }

                  // Retry original request
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $_token';
                  final retryResponse = await dio.fetch(opts);
                  return handler.resolve(retryResponse);
                }
              }
            }

            // If we reach here, refresh failed or no token was available
            _token = null;
            await prefs.remove('auth_token');
            await prefs.remove('auth_refresh_token');
          } catch (e) {
            _token = null;
          }
        }
        return handler.next(error);
      },
    ));
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }
}