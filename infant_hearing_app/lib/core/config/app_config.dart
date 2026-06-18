import 'package:flutter/foundation.dart';

enum Environment { dev, staging, prod }

class AppConfig {
  /// Current environment. Defaults to 'dev'.
  /// Can be set via --dart-define=ENV=prod
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static Environment get environment {
    switch (_env.toLowerCase()) {
      case 'prod':
        return Environment.prod;
      case 'staging':
        return Environment.staging;
      default:
        return Environment.dev;
    }
  }

  /// Base URL for the API.
  /// If provided via --dart-define=API_URL=..., it takes precedence.
  /// Otherwise, it falls back to environment-specific defaults.
  static String get apiBaseUrl {
    const injectedUrl = String.fromEnvironment('API_URL');
    if (injectedUrl.isNotEmpty) return injectedUrl;

    switch (environment) {
      case Environment.prod:
        return "https://api.baalshravya.org/api";
      case Environment.staging:
        return "https://staging.baalshravya.org/api";
      case Environment.dev:
        // mDNS fallback: Many developers use .local for local development.
        // On Android Emulator, 10.0.2.2 points to host machine.
        if (kIsWeb) return "http://localhost:5000/api";
        return "http://baalshravya-api.local:5000/api";
    }
  }

  /// Whether to use mock services.
  static const bool useMocks = bool.fromEnvironment('USE_MOCKS', defaultValue: false);

  /// Whether to use Firebase for ASHA module (V2 architecture).
  static const bool useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: true);

  static bool get isDev => environment == Environment.dev;
  static bool get isProd => environment == Environment.prod;
}
