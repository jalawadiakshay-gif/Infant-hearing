/// Centralised route name constants.
/// Import this wherever you call Navigator.pushNamed().
abstract class RouteConstants {
  // ── Bootstrap ──────────────────────────────────────────────────
  static const String root           = '/';
  static const String languageSelect = '/language-select';

  // ── Auth ───────────────────────────────────────────────────────
  static const String login           = '/login';
  static const String register        = '/register';
  static const String phoneLogin      = '/phone-login';
  static const String otpVerification = '/otp-verification';
  static const String roleSelection   = '/role-selection';

  // ── Profile ────────────────────────────────────────────────────
  static const String profile              = '/profile';
  static const String parentInfo           = '/parent-info';
  static const String parentProfile        = '/parent-profile';
  static const String babyProfile          = '/baby-profile';
  static const String simpleParentProfile  = '/simple-parent-profile';
  static const String childDetail          = '/child-detail';

  // ── Core flow ──────────────────────────────────────────────────
  static const String home                = '/home';
  static const String mainLayout          = '/mainLayout';
  static const String screeningTab        = '/screening-tab';
  static const String questionnaire       = '/questionnaire';
  static const String questionnaireResult = '/questionnaire-result';

  // ── Features ───────────────────────────────────────────────────
  static const String chatbot  = '/chatbot';
  static const String settings = '/settings';
  static const String history  = '/history';
  static const String medicalInsights = '/medical-insights';

  // ── BOA Module ─────────────────────────────────────────────────
  static const String boaTest      = '/boa-test';     // legacy alias kept
  static const String boaIntro     = '/boa-intro';
  static const String boaChecklist = '/boa-checklist';
  static const String boaResult    = '/boa-result';
}