/// LocalStorageService
///
/// Phase 1: In-memory stub.
/// Phase 2: Replace with SharedPreferences / SQLite / Hive.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final Map<String, dynamic> _store = {};

  void write(String key, dynamic value) {
    _store[key] = value;
  }

  T? read<T>(String key) {
    return _store[key] as T?;
  }

  void delete(String key) {
    _store.remove(key);
  }

  void clearAll() {
    _store.clear();
  }

  bool containsKey(String key) => _store.containsKey(key);
}
