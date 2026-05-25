class Logger {
  static void log(dynamic message) {
    // ignore: avoid_print
    print("🔹 $message");
  }

  static void error(dynamic message) {
    // ignore: avoid_print
    print("❌ ERROR: $message");
  }
}