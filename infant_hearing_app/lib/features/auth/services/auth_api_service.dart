import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthApiService {
  final ApiClient apiClient;

  AuthApiService(this.apiClient);

  Future<void> sendOtp(String phone) async {
    await apiClient.post(ApiEndpoints.sendOtp, body: {
      "phone": phone,
    });
  }

  Future<String> verifyOtp(String phone, String otp) async {
    final response = await apiClient.post(ApiEndpoints.verifyOtp, body: {
      "phone": phone,
      "otp": otp,
    });

    return response['token'] ?? '';
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    await apiClient.post(ApiEndpoints.register, body: {
      "fullName": fullName,
      "email": email,
      "password": password,
      "phone": phone,
    });
  }

  Future<String> login(String email, String password) async {
    final response = await apiClient.post(ApiEndpoints.login, body: {
      "email": email,
      "password": password,
    });

    return response['token'] ?? '';
  }
}
