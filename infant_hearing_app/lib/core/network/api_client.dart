import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/logger.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import '../../shared/services/local_storage_service.dart';

import '../constants/env.dart';

class ApiClient {
  final String baseUrl;
  final LocalStorageService storage;

  ApiClient({
    required this.baseUrl,
    required this.storage,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = storage.getToken();

    return AuthInterceptor.getHeaders(token: token);
  }

  Future<dynamic> get(String endpoint) async {
    // TEMP MOCK: Block real GET calls during frontend development
    if (Env.useMocks) {
      Logger.log("MOCK API [GET] BLOCKED: $endpoint");
      throw ApiException("Network error: Backend connectivity is disabled in Env.useMocks mode.");
    }
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl$endpoint');

      Logger.log("API REQUEST [GET]: $url");
      Logger.log("HEADERS: $headers");

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Network error: $e");
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body}) async {
    // TEMP MOCK: Block real POST calls during frontend development
    if (Env.useMocks) {
      Logger.log("MOCK API [POST] BLOCKED: $endpoint");
      throw ApiException("Network error: Backend connectivity is disabled in Env.useMocks mode.");
    }
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl$endpoint');
      final bodyStr = jsonEncode(body);

      Logger.log("API REQUEST [POST]: $url");
      Logger.log("HEADERS: $headers");
      Logger.log("BODY: $bodyStr");

      final response = await http
          .post(
            url,
            headers: headers,
            body: bodyStr,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Network error: $e");
    }
  }

  dynamic _handleResponse(http.Response response) {
    Logger.log("API RESPONSE CODE: ${response.statusCode}");
    
    dynamic data;
    try {
      data = jsonDecode(response.body);
      Logger.log("API RESPONSE BODY: $data");
    } catch (e) {
      final raw = response.body;
      final snippet = raw.length > 100 ? raw.substring(0, 100) : raw;
      Logger.log("API RESPONSE BODY (NON-JSON): $snippet...");
      throw ApiException("Invalid server response (Non-JSON). Please check your backend URL.", statusCode: response.statusCode);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errorMessage = (data is Map) ? (data['message'] ?? data['error'] ?? "Unknown error") : "Unknown error";
      throw ApiException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }
  }
}