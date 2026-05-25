import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infant_hearing_app/core/constants/app_language.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _key = 'selected_language_code';
  static const String _firstRunKey = 'is_first_run';

  AppLanguage _language = AppLanguage.english;
  bool _initialized = false;
  bool _isFirstRun = true;

  LanguageProvider() {
    _language = _getSystemAppLanguage();
  }

  // ── Getters ──────────────────────────────────────────────────────────────
  AppLanguage get language => _language;
  AppLanguage get currentLanguage => _language;
  Locale get locale => Locale(_language.code);
  bool get initialized => _initialized;
  bool get isFirstRun => _isFirstRun;

  String get languageCode => _language.code;
  String get ttsLocale => _language.ttsLocale;
  String get sttLocale => _language.sttLocale;

  // ── Initialization ───────────────────────────────────────────────────────
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    _isFirstRun = prefs.getBool(_firstRunKey) ?? true;
    
    if (saved != null) {
      _language = AppLanguage.fromCode(saved);
    } else {
      _language = _getSystemAppLanguage();
    }
    
    _initialized = true;
    notifyListeners();
  }

  AppLanguage _getSystemAppLanguage() {
    final systemLocale = PlatformDispatcher.instance.locale.languageCode;
    return AppLanguage.values.firstWhere(
      (l) => l.code == systemLocale,
      orElse: () => AppLanguage.english,
    );
  }

  // ── Mutation ─────────────────────────────────────────────────────────────
  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    _isFirstRun = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang.code);
    await prefs.setBool(_firstRunKey, false);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final lang = AppLanguage.fromCode(locale.languageCode);
    await setLanguage(lang);
  }
}
