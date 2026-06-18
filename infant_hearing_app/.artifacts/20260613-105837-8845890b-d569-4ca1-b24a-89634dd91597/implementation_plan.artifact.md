# Redesigning Networking Layer for Dynamic Environments

This plan outlines a production-grade architecture to eliminate manual IP updates and support multi-environment configurations (Dev, Staging, Prod).

## Comparison of Connectivity Solutions

| Solution | Effort | Reliability | Scalability | Recommendation |
| :--- | :--- | :--- | :--- | :--- |
| **Local IP** | High (Manual) | Medium | Low | ❌ **Discard** |
| **mDNS (.local)** | Low | High | Medium | ✅ **Recommended for Dev** |
| **Localtunnel/Ngrok** | Medium | Medium | Medium | ⚠️ **Backup for Dev** |
| **Cloud Run/Firebase** | High | High | High | ✅ **Recommended for Staging/Prod** |

## Proposed Architecture

### 1. Multi-Environment Configuration
We will use **Dart Environment Variables** (`--dart-define`) to inject configuration at compile-time. This allows switching environments without code changes.

### 2. Scalable Env Configuration
#### [NEW] [app_config.dart](file:///D:/Infant_hearing/infant_hearing_app/lib/core/config/app_config.dart)
A central repository for all environment-specific settings.

```dart
enum Environment { dev, staging, prod }

class AppConfig {
  static const String envName = String.fromEnvironment('ENV', defaultValue: 'dev');

  static Environment get environment {
    switch (envName) {
      case 'prod': return Environment.prod;
      case 'staging': return Environment.staging;
      default: return Environment.dev;
    }
  }

  static String get apiBaseUrl {
    // Injectable via --dart-define=API_URL=...
    const injectedUrl = String.fromEnvironment('API_URL');
    if (injectedUrl.isNotEmpty) return injectedUrl;

    switch (environment) {
      case Environment.prod: return "https://api.baalshravya.org/api";
      case Environment.staging: return "https://staging.baalshravya.org/api";
      case Environment.dev: return "http://baalshravya-api.local:5000/api";
    }
  }
}
```

### 3. Smart Connectivity Layer
#### [REFACTOR] [api_client.dart](file:///D:/Infant_hearing/infant_hearing_app/lib/core/network/api_client.dart)
Implement a fallback mechanism to handle local network unpredictability.

```dart
// logic snippet
Future<String> _resolveBaseUrl() async {
  if (AppConfig.environment != Environment.dev) return AppConfig.apiBaseUrl;

  // 1. Try mDNS (.local)
  // 2. Fallback to Local IP auto-discovery (if needed)
  // 3. Fallback to Tunnel URL (if provided)
}
```

## Proposed Changes

### Core Configuration

#### [DELETE] [env.dart](file:///D:/Infant_hearing/infant_hearing_app/lib/core/constants/env.dart)

#### [NEW] [app_config.dart](file:///D:/Infant_hearing/infant_hearing_app/lib/core/config/app_config.dart)

- Implements the `AppConfig` class shown above.
- Centralizes all environment toggles (Firebase, Mocking, etc.).

---

### Networking Layer

#### [api_client.dart](file:///D:/Infant_hearing/infant_hearing_app/lib/core/network/api_client.dart)

- Integrate `AppConfig.apiBaseUrl`.
- Add retry logic for common network failures.
- Implement specialized timeout handling for different environments.

---

### Build Automation

#### [NEW] [launch.json](file:///D:/Infant_hearing/infant_hearing_app/.vscode/launch.json)
Pre-configure IDE to launch with specific flavors.

```json
{
  "configurations": [
    {
      "name": "App (Dev)",
      "request": "launch",
      "type": "dart",
      "args": ["--dart-define=ENV=dev", "--dart-define=API_URL=http://baalshravya-api.local:5000/api"]
    }
  ]
}
```

## Migration Steps
1. Create `AppConfig` and migrate all `Env` properties.
2. Update `ApiClient` to use `AppConfig`.
3. Set up build flavors in Android (`build.gradle.kts`) and iOS (Schemes).
4. Provide a script to run the app with preferred defaults.

## Verification Plan

### Automated Tests
- Run `flutter analyze`.
- Unit test for `AppConfig` to ensure correct resolution of variables based on `--dart-define`.

### Manual Verification
- Launch app with different `--dart-define` values and verify `ApiClient` uses the correct `baseUrl`.
- Test local connectivity using the `.local` hostname.
