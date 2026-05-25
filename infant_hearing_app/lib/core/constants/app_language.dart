/// Single source of truth for every language-dependent subsystem.
///
/// Adding a new language = add one enum value + update the switch tables below.
enum AppLanguage {
  english('en', 'English', 'English', 'en-IN', 'en_IN'),
  hindi('hi', 'हिंदी', 'Hindi', 'hi-IN', 'hi_IN'),
  kannada('kn', 'ಕನ್ನಡ', 'Kannada', 'kn-IN', 'kn_IN'),
  marathi('mr', 'मराठी', 'Marathi', 'mr-IN', 'mr_IN');

  const AppLanguage(
    this.code,
    this.nativeName,
    this.englishName,
    this.ttsLocale,   // BCP-47 for flutter_tts
    this.sttLocale,   // underscore format for speech_to_text
  );

  /// ISO 639-1 language code. Used as ARB file suffix and API param.
  final String code;

  /// Name shown in the UI in the language itself.
  final String nativeName;

  /// Name shown in English (for accessibility / fallback labels).
  final String englishName;

  /// BCP-47 locale string for flutter_tts  (e.g. 'hi-IN').
  final String ttsLocale;

  /// Locale string for speech_to_text       (e.g. 'hi_IN').
  final String sttLocale;

  /// Dart [Locale] object consumed by [MaterialApp].
  // ignore: avoid_classes_with_only_static_members
  // (Locale is from dart:ui — we keep the dependency in the enum, not in the widget tree)
  // Returns Locale(code) — e.g. Locale('hi')
  String get localeTag => code;

  static AppLanguage fromCode(String code) => AppLanguage.values.firstWhere(
        (l) => l.code == code,
        orElse: () => AppLanguage.english,
      );
}