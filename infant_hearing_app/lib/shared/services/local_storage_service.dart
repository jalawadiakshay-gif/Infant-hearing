import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin, injectable wrapper around SharedPreferences.
///
/// Call [initialize] once in main() before runApp.
/// All other methods are synchronous after init (prefs is cached).
class LocalStorageService extends ChangeNotifier {
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null,
        'LocalStorageService.initialize() was not called before use.');
    return _prefs!;
  }

  // ── String ────────────────────────────────────────────────────
  Future<bool> setString(String key, String value) =>
      _p.setString(key, value);
  String? getString(String key) => _p.getString(key);

  // ── Bool ─────────────────────────────────────────────────────
  Future<bool> setBool(String key, {required bool value}) =>
      _p.setBool(key, value);
  bool? getBool(String key) => _p.getBool(key);

  // ── Int ──────────────────────────────────────────────────────
  Future<bool> setInt(String key, int value) => _p.setInt(key, value);
  int? getInt(String key) => _p.getInt(key);

  // ── Double ───────────────────────────────────────────────────
  Future<bool> setDouble(String key, double value) =>
      _p.setDouble(key, value);
  double? getDouble(String key) => _p.getDouble(key);

  // ── String list ──────────────────────────────────────────────
  Future<bool> setStringList(String key, List<String> value) =>
      _p.setStringList(key, value);
  List<String>? getStringList(String key) => _p.getStringList(key);

  // ── Auth Token ──────────────────────────────────────────────
  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) => _p.setString(_tokenKey, token);
  String? getToken() => _p.getString(_tokenKey);
  Future<void> removeToken() => _p.remove(_tokenKey);

  // ── Removal ──────────────────────────────────────────────────
  Future<bool> remove(String key) => _p.remove(key);
  Future<bool> clear() => _p.clear();
  bool containsKey(String key) => _p.containsKey(key);
}