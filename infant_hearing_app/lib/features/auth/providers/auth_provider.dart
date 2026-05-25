import 'package:flutter/material.dart';
import '../../../shared/repositories/auth_repository.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  String? _phoneNumber;

  AuthProvider({required this.authRepository});

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => authRepository.isLoggedIn();
  String? get phoneNumber => _phoneNumber;

  void _setStatus(AuthStatus status, {String? error}) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _setStatus(AuthStatus.loading);
    try {
      await authRepository.sendOtp(phone);
      _phoneNumber = phone;
      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_phoneNumber == null) {
      _setStatus(AuthStatus.error, error: "Phone number missing");
      return false;
    }

    _setStatus(AuthStatus.loading);
    try {
      final success = await authRepository.verifyOtp(_phoneNumber!, otp);
      if (success) {
        _setStatus(AuthStatus.success);
        return true;
      } else {
        _setStatus(AuthStatus.error, error: 'Verification failed');
        return false;
      }
    } catch (e) {
      _setStatus(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      await authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );
      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      final success = await authRepository.login(
        email: email,
        password: password,
      );
      if (success) {
        _setStatus(AuthStatus.success);
        return true;
      } else {
        _setStatus(AuthStatus.error, error: 'Login failed');
        return false;
      }
    } catch (e) {
      _setStatus(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _phoneNumber = null;
    _setStatus(AuthStatus.idle);
  }

  void reset() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // Google sign-in is currently mocked as per original implementation but should ideally be in Repository
  Future<bool> signInWithGoogle() async {
    _setStatus(AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 1500));
    // Here we would call authRepository.signInWithGoogle()
    _setStatus(AuthStatus.success);
    return true;
  }
}