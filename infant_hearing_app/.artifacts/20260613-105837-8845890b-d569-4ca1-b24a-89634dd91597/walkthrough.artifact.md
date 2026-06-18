# Walkthrough - Fixing Language Change and Network Timeout Issues

I have addressed the disruptive navigation during language changes and improved the app's resilience to network timeouts.

## 1. Language Change Persistence
Previously, changing the language would reset the app to the Dashboard because the `GoRouter` was being recreated.

### Solution
- Refactored `InfantHearingApp` into a `StatefulWidget`.
- Initialized `GoRouter` in `initState` to ensure a stable instance across rebuilds.
- This ensures the user stays on the same screen (e.g., Phase 1 Screening) when they change the language.

## 2. Network Timeout Handling
The user reported a "TimeoutException" after 30 seconds on the login screen.

### Solution
- **Increased Timeout**: Doubled the default network timeout from 30 seconds to **60 seconds** in `ApiClient`.
- **Improved Error Message**: Added specific handling for `TimeoutException`. Instead of a technical "Future not completed" error, users will now see: *"The server took too long to respond. Please check your network connection and ensure the server is reachable."*
- **Configurable Timeouts**: Added an optional `timeout` parameter to `get` and `post` methods in `ApiClient`, allowing for longer timeouts on specific slow requests if needed.

## Verification Results

### Automated Tests
- Ran `flutter analyze` on `lib/app.dart` and `lib/core/network/api_client.dart`. No issues found.

### Manual Verification Recommended
- **Timeout Check**: Ensure that if a timeout occurs, the new user-friendly message is displayed.
- **Connectivity Check**: Verify that the `baseUrl` in `lib/core/constants/env.dart` is correct and reachable from the testing device.
- **Language Toggle**: Confirm that toggling language during a questionnaire no longer navigates back to the Dashboard.
