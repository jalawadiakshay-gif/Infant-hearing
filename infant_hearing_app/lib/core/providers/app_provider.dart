import 'package:flutter/material.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/parent/providers/parent_provider.dart';
import '../../features/baby/providers/baby_provider.dart';

class AppProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final ParentProvider parentProvider;
  final BabyProvider babyProvider;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppProvider({
    required this.authProvider,
    required this.parentProvider,
    required this.babyProvider,
  });

  Future<void> initializeApp() async {
    debugPrint('AppProvider: Initializing...');
    _isInitialized = false;
    notifyListeners();

    if (authProvider.isAuthenticated) {
      debugPrint('AppProvider: Authenticated, providers will auto-fetch via streams...');
    }
    _isInitialized = true;
    debugPrint('AppProvider: Initialized');
    notifyListeners();
  }
}