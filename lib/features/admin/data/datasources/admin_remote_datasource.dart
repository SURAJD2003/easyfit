import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easyfit_clinics/core/api_constants.dart';
import '../models/index.dart';

class AdminRemoteDataSource {
  final http.Client client;
  final String baseUrl = ApiConstants.adminBaseUrl;

  AdminRemoteDataSource({required this.client});

  Map<String, String> _headers(String token) => {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  void _handleError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    var message = 'API Error ${response.statusCode}';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        message = decoded['detail']?.toString() ??
            decoded['title']?.toString() ??
            decoded['message']?.toString() ??
            message;
      } else if (response.body.isNotEmpty) {
        message = response.body;
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }
    throw Exception(message);
  }

  dynamic _unwrapBody(http.Response response) {
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }

  // ─── AUTH ───────────────────────────────────────────────────────────────
  Future<AdminLoginModel> login({
    required String email,
    required String password,
  }) async {
    final res = await client.post(
      Uri.parse('$baseUrl${ApiConstants.adminLogin}'),
      headers: const {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password.trim(),
      }),
    );
    _handleError(res);
    return AdminLoginModel.fromJson(_unwrapBody(res) as Map<String, dynamic>);
  }

  // ─── USERS ──────────────────────────────────────────────────────────────
  Future<List<AdminUserModel>> getAllUsers({
    required String token,
    int? page,
    int? limit,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (page != null) queryParams['Page'] = page.toString();
    if (limit != null) queryParams['Limit'] = limit.toString();
    if (search != null && search.isNotEmpty) queryParams['Search'] = search;

    final uri = Uri.parse('$baseUrl${ApiConstants.adminUsers}').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final res = await client.get(uri, headers: _headers(token));
    _handleError(res);
    final data = _unwrapBody(res);

    if (data is List) {
      return data
          .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic> && data.containsKey('users')) {
      return (data['users'] as List)
          .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<AdminUserModel> getUserDetail({
    required String token,
    required String userId,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl${ApiConstants.adminUserDetail(userId)}'),
      headers: _headers(token),
    );
    _handleError(res);
    return AdminUserModel.fromJson(_unwrapBody(res) as Map<String, dynamic>);
  }

  Future<void> deleteUser({
    required String token,
    required String userId,
  }) async {
    final res = await client.delete(
      Uri.parse('$baseUrl${ApiConstants.adminUserDetail(userId)}'),
      headers: _headers(token),
    );
    _handleError(res);
  }

  Future<void> activateUser({
    required String token,
    required String userId,
  }) async {
    final res = await client.patch(
      Uri.parse('$baseUrl${ApiConstants.adminUserDetail(userId)}/activate'),
      headers: _headers(token),
    );
    _handleError(res);
  }

  Future<void> deactivateUser({
    required String token,
    required String userId,
    String? reason,
  }) async {
    final res = await client.patch(
      Uri.parse('$baseUrl${ApiConstants.adminUserDetail(userId)}/deactivate'),
      headers: _headers(token),
      body: jsonEncode({'reason': reason ?? 'Deactivated by admin'}),
    );
    _handleError(res);
  }

  // ─── SUBSCRIPTIONS ──────────────────────────────────────────────────────
  Future<List<SubscriptionModel>> getSubscriptions({
    required String token,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl${ApiConstants.adminSubscriptions}'),
      headers: _headers(token),
    );
    _handleError(res);
    final data = _unwrapBody(res);

    if (data is List) {
      return data
          .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<List<SubscriptionModel>> getDueSubscriptions({
    required String token,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl${ApiConstants.adminDueSubscriptions}'),
      headers: _headers(token),
    );
    _handleError(res);
    final data = _unwrapBody(res);

    if (data is List) {
      return data
          .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<List<SubscriptionModel>> getExpiredSubscriptions({
    required String token,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl${ApiConstants.adminExpiredSubscriptions}'),
      headers: _headers(token),
    );
    _handleError(res);
    final data = _unwrapBody(res);

    if (data is List) {
      return data
          .map((e) => SubscriptionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<SubscriptionModel> getSubscriptionDetail({
    required String token,
    required String subId,
  }) async {
    final res = await client.get(
      Uri.parse('$baseUrl${ApiConstants.adminSubscriptionDetail(subId)}'),
      headers: _headers(token),
    );
    _handleError(res);
    return SubscriptionModel.fromJson(_unwrapBody(res) as Map<String, dynamic>);
  }
  Future<void> approveSubscription({
    required String token,
    required String subId,
    String? note,
  }) async {
    final res = await client.patch(
      Uri.parse('$baseUrl${ApiConstants.adminApproveSubscription(subId)}'),
      headers: _headers(token),
      body: jsonEncode({'note': note ?? ''}),
    );
    _handleError(res);
  }

  Future<void> rejectSubscription({
    required String token,
    required String subId,
    String? reason,
  }) async {
    final res = await client.patch(
      Uri.parse('$baseUrl${ApiConstants.adminRejectSubscription(subId)}'),
      headers: _headers(token),
      body: jsonEncode({'reason': reason ?? ''}),
    );
    _handleError(res);
  }

  Future<void> updateSubscription({
    required String token,
    required String subId,
    required Map<String, dynamic> data,
  }) async {
    final res = await client.patch(
      Uri.parse('$baseUrl${ApiConstants.adminSubscriptionDetail(subId)}'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    _handleError(res);
  }

  Future<void> grantSubscription({
    required String token,
    required String userId,
    required String planId,
    String? expiryDate,
    String? reason,
  }) async {
    final res = await client.patch(
      Uri.parse('$baseUrl${ApiConstants.adminGrantSubscription(userId)}'),
      headers: _headers(token),
      body: jsonEncode({
        'planId': planId,
        'expiryDate': expiryDate ?? '',
        'reason': reason ?? '',
      }),
    );
    _handleError(res);
  }



  // ─── ANALYTICS ──────────────────────────────────────────────────────────
  Future<AnalyticsModel> getAnalytics({required String token}) async {
    final res = await client.get(
      Uri.parse('$baseUrl${ApiConstants.adminAnalytics}'),
      headers: _headers(token),
    );
    _handleError(res);
    return AnalyticsModel.fromJson(_unwrapBody(res) as Map<String, dynamic>);
  }

  // ─── NOTIFICATIONS ──────────────────────────────────────────────────────
  Future<void> broadcastNotification({
    required String token,
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    final res = await client.post(
      Uri.parse('$baseUrl${ApiConstants.adminNotificationsBroadcast}'),
      headers: _headers(token),
      body: jsonEncode({
        'title': title.trim(),
        'body': body.trim(),
        'imageUrl': imageUrl?.trim() ?? '',
      }),
    );
    _handleError(res);
  }

  Future<void> segmentNotification({
    required String token,
    required String title,
    required String body,
    required String segment,
  }) async {
    final res = await client.post(
      Uri.parse('$baseUrl${ApiConstants.adminNotificationsSegment}'),
      headers: _headers(token),
      body: jsonEncode({
        'title': title.trim(),
        'body': body.trim(),
        'segment': segment.trim(),
      }),
    );
    _handleError(res);
  }

  // ─── REPORTS ────────────────────────────────────────────────────────────
  Future<ReportModel> getReports({
    required String token,
    String? from,
    String? to,
  }) async {
    final queryParams = <String, String>{};
    if (from != null && from.isNotEmpty) queryParams['From'] = from;
    if (to != null && to.isNotEmpty) queryParams['To'] = to;

    final uri = Uri.parse('$baseUrl${ApiConstants.adminReportsOverview}')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final res = await client.get(uri, headers: _headers(token));
    _handleError(res);
    return ReportModel.fromJson(_unwrapBody(res) as Map<String, dynamic>);
  }
}
