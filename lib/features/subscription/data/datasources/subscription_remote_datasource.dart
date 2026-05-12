import 'package:dio/dio.dart';
import '../../../../core/api_client.dart';
import '../../../../core/api_constants.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_status_model.dart';
import '../models/subscription_request_status_model.dart';

class SubscriptionRemoteDataSource {
  final Dio _dio = ApiClient().dio;
  
  // Create a separate Dio instance for endpoints that don't use the /api prefix
  late final Dio _baseDio;

  SubscriptionRemoteDataSource() {
    _baseDio = Dio(BaseOptions(
      baseUrl: ApiConstants.adminBaseUrl, // https://api.theeasyfitclinics.com
      headers: _dio.options.headers,
    ));
    
    // Add interceptors to sync with main dio if needed (e.g. auth token)
    _baseDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ApiClient().token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      final response = await _dio.get(ApiConstants.subscriptionPlans);
      if (response.statusCode == 200) {
        final List<dynamic> plansJson = response.data['plans'];
        return plansJson
            .map((json) => SubscriptionPlanModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load subscription plans');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifySubscription({
    required String platform,
    required String receiptData,
    required String planId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.subscriptionVerify,
        data: {
          'platform': platform,
          'receiptData': receiptData,
          'planId': planId,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserSubscriptionStatusModel> getSubscriptionStatus() async {
    try {
      final response = await _dio.get(ApiConstants.subscriptionStatus);
      return UserSubscriptionStatusModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelSubscription() async {
    try {
      final response = await _dio.post(ApiConstants.subscriptionCancel);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> restoreSubscription({
    required String platform,
    required String receiptData,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.subscriptionRestore,
        data: {
          'platform': platform,
          'receiptData': receiptData,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ── Manual Subscription Requests (Without /api prefix) ──

  Future<Map<String, dynamic>> requestSubscription(String planId) async {
    try {
      final response = await _baseDio.post(
        ApiConstants.subRequest,
        data: {'plan': planId},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<SubscriptionRequestStatusModel> getRequestStatus() async {
    try {
      final response = await _baseDio.get(ApiConstants.subStatus);
      return SubscriptionRequestStatusModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
