/// Global Environment Configuration
/// Toggle [useMocks] to true for frontend-only development without a backend.
class Env {
  // TEMP MOCK: Set to true for frontend-only offline development
  static const bool useMocks = true;

  // Development server URL (unused when useMocks is true)
  static const String baseUrl = "https://unused-flock-gopher.ngrok-free.dev/api";
}
