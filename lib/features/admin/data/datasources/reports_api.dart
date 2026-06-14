import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report_model.dart';

class ReportsApi {
  final http.Client client;
  final String baseUrl;

  ReportsApi({http.Client? client, this.baseUrl = 'https://uat-api.theeasyfitclinics.com'})
      : client = client ?? http.Client();

  Map<String, String> _headers(String token) => {
        'accept': 'text/plain',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  void _handleError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    var message = 'API Error ${response.statusCode}';
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        message = body['detail']?.toString() ??
            body['title']?.toString() ??
            body['message']?.toString() ??
            message;
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw Exception(message);
  }

  Future<ReportModel> fetchOverview({
    required String token,
    String? from,
    String? to,
  }) async {
    final queryParams = <String, String>{};
    if (from != null && from.isNotEmpty) queryParams['From'] = from;
    if (to != null && to.isNotEmpty) queryParams['To'] = to;

    final uri = Uri.parse('$baseUrl/api/admin/reports/overview')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await client.get(uri, headers: _headers(token));
    _handleError(response);

    final decoded = jsonDecode(response.body);
    final body = decoded is Map<String, dynamic> && decoded.containsKey('data')
        ? decoded['data']
        : decoded;

    return ReportModel.fromJson(body as Map<String, dynamic>);
  }
}
