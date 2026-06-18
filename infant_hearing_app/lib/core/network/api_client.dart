import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/logger.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import '../../shared/services/local_storage_service.dart';

class ApiClient {
  final LocalStorageService storage;
  String? _manualBaseUrl;

  ApiClient({
    required this.storage,
    String? baseUrl,
  }) : _manualBaseUrl = baseUrl;

  String get baseUrl {
    if (_manualBaseUrl != null) return _manualBaseUrl!;
    return AppConfig.apiBaseUrl;
  }

  /// Allows updating the base URL at runtime (e.g., after discovery)
  void updateBaseUrl(String newUrl) {
    _manualBaseUrl = newUrl;
    Logger.log("API Client: Base URL updated to $newUrl");
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = storage.getToken();
    return AuthInterceptor.getHeaders(token: token);
  }

  Future<dynamic> get(String endpoint, {Duration? timeout}) async {
    if (AppConfig.useMocks) {
      Logger.log("MOCK API [GET] BLOCKED: $endpoint");
      throw ApiException("Network error: Backend connectivity is disabled in Mock mode.");
    }

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl$endpoint');

      Logger.log("API REQUEST [GET]: $url");

      final response = await http
          .get(url, headers: headers)
          .timeout(timeout ?? _getTimeout());

      return _handleResponse(response);
    } on SocketException catch (e) {
      Logger.error("SocketException: ${e.message}");
      throw ApiException(_getConnectivityErrorMessage());
    } on TimeoutException {
      throw ApiException("The server took too long to respond. Please check your network connection.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Network error: $e");
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body, Duration? timeout}) async {
    if (AppConfig.useMocks) {
      Logger.log("MOCK API [POST] BLOCKED: $endpoint");
      throw ApiException("Network error: Backend connectivity is disabled in Mock mode.");
    }

    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl$endpoint');
      final bodyStr = jsonEncode(body);

      Logger.log("API REQUEST [POST]: $url");

      final response = await http
          .post(url, headers: headers, body: bodyStr)
          .timeout(timeout ?? _getTimeout());

      return _handleResponse(response);
    } on SocketException catch (e) {
      Logger.error("SocketException: ${e.message}");
      throw ApiException(_getConnectivityErrorMessage());
    } on TimeoutException {
      throw ApiException("The server took too long to respond. Please check your network connection.");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Network error: $e");
    }
  }

  Duration _getTimeout() {
    return AppConfig.isProd ? const Duration(seconds: 30) : const Duration(seconds: 60);
  }

  String _getConnectivityErrorMessage() {
    if (AppConfig.isDev) {
      return "Could not connect to the development server at $baseUrl. "
          "Ensure your backend is running and reachable on this network.";
    }
    return "Could not connect to the server. Please check your internet connection.";
  }

  dynamic _handleResponse(http.Response response) {
    Logger.log("API RESPONSE CODE: ${response.statusCode}");
    
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (e) {
      throw ApiException("Invalid server response (Non-JSON).", statusCode: response.statusCode);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data is Map<String, dynamic> && data.containsKey('success')) {
        if (data['success'] == true) {
          return data['data'] ?? data;
        } else {
          throw ApiException(data['message'] ?? "Operation failed", statusCode: response.statusCode);
        }
      }
      return data;
    } else {
      final errorMessage = (data is Map) ? (data['message'] ?? data['error'] ?? "Unknown error") : "Unknown error";
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}
