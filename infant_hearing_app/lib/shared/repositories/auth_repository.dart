import '../../features/auth/services/auth_api_service.dart';
import '../services/local_storage_service.dart';
import '../../core/constants/env.dart';

class AuthRepository {
  final AuthApiService authApiService;
  final LocalStorageService storage;

  AuthRepository({
    required this.authApiService,
    required this.storage,
  });

  Future<void> sendOtp(String phone) async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    await authApiService.sendOtp(phone);
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(seconds: 1));
      if (otp == "123456" || otp.length == 6) {
        await storage.saveToken("mock_token_123");
        return true;
      }
      return false;
    }
    
    final token = await authApiService.verifyOtp(phone, otp);
    if (token.isNotEmpty) {
      await storage.saveToken(token);
      return true;
    }
    return false;
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }
    await authApiService.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (Env.useMocks) {
      await Future.delayed(const Duration(seconds: 1));
      await storage.saveToken("mock_token_123");
      return true;
    }
    
    final token = await authApiService.login(email, password);
    if (token.isNotEmpty) {
      await storage.saveToken(token);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await storage.removeToken();
  }

  bool isLoggedIn() {
    return storage.getToken() != null;
  }
}
