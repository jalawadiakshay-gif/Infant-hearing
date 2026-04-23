import 'package:flutter/material.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // In-memory user store (Phase 1 — no backend)
  final List<Map<String, String>> _users = [];

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  void _setStatus(AuthStatus status, {String? error}) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setStatus(AuthStatus.loading);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Check duplicate email
    final exists = _users.any(
      (u) => u['email']?.toLowerCase() == email.toLowerCase(),
    );
    if (exists) {
      _setStatus(AuthStatus.error, error: 'An account with this email already exists.');
      return false;
    }

    _users.add({
      'fullName': fullName,
      'email': email.toLowerCase(),
      'password': password,
      'phone': phone,
    });

    _setStatus(AuthStatus.success);
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);

    await Future.delayed(const Duration(milliseconds: 1000));

    // For demo: allow any valid format login or check registered users
    final user = _users.firstWhere(
      (u) =>
          u['email']?.toLowerCase() == email.toLowerCase() &&
          u['password'] == password,
      orElse: () => {},
    );

    // Demo mode: if no registered users, allow demo login
    if (user.isEmpty && _users.isEmpty) {
      _isAuthenticated = true;
      _setStatus(AuthStatus.success);
      return true;
    }

    if (user.isEmpty) {
      _setStatus(AuthStatus.error, error: 'Invalid email or password. Please try again.');
      return false;
    }

    _isAuthenticated = true;
    _setStatus(AuthStatus.success);
    return true;
  }

  void logout() {
    _isAuthenticated = false;
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
