import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum SttStatus { idle, listening, done, error, unavailable }

class SpeechService extends ChangeNotifier {
  final SpeechToText _stt = SpeechToText();

  SttStatus _status = SttStatus.idle;
  String _lastWords = '';
  String _errorMessage = '';
  bool _available = false;

  SttStatus get status => _status;
  String get lastWords => _lastWords;
  String get errorMessage => _errorMessage;
  bool get isAvailable => _available;
  bool get isListening => _status == SttStatus.listening;

  // ── Init ─────────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    try {
      _available = await _stt.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: kDebugMode,
      );
      if (!_available) {
        _status = SttStatus.unavailable;
        _errorMessage = 'Speech recognition not available on this device.';
      }
    } catch (e) {
      _available = false;
      _status = SttStatus.unavailable;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ── Listen ───────────────────────────────────────────────────────────────
  Future<void> startListening({
    required String sttLocale,
    required void Function(String words, bool isFinal) onResult,
    Duration listenFor = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_available) {
      _status = SttStatus.unavailable;
      notifyListeners();
      return;
    }
    if (_stt.isListening) await stopListening();

    _lastWords = '';
    _status = SttStatus.listening;
    notifyListeners();

    final resolved = await _resolveLocale(sttLocale);

    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        _lastWords = result.recognizedWords;
        if (result.finalResult) _status = SttStatus.done;
        notifyListeners();
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: SpeechListenOptions(
        localeId: resolved,
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
    _status = SttStatus.idle;
    notifyListeners();
  }

  Future<void> cancelListening() async {
    await _stt.cancel();
    _status = SttStatus.idle;
    _lastWords = '';
    notifyListeners();
  }

  // ── Locale resolution ────────────────────────────────────────────────────
  Future<String> _resolveLocale(String requested) async {
    try {
      final locales = await _stt.locales();
      final exact = locales.any(
        (l) => l.localeId.toLowerCase() == requested.toLowerCase(),
      );
      if (exact) return requested;

      final lang = requested.split('_').first.toLowerCase();
      final partial = locales.firstWhere(
        (l) => l.localeId.toLowerCase().startsWith(lang),
        orElse: () => locales.firstWhere(
          (l) => l.localeId.startsWith('en'),
          orElse: () => locales.first,
        ),
      );
      return partial.localeId;
    } catch (_) {
      return 'en_IN';
    }
  }

  // ── Callbacks ─────────────────────────────────────────────────────────────
  void _onError(SpeechRecognitionError error) {
    _status = SttStatus.error;
    _errorMessage = error.errorMsg;
    notifyListeners();
  }

  void _onStatus(String status) {
    if ((status == 'done' || status == 'notListening') &&
        _status == SttStatus.listening) {
      _status = SttStatus.idle;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stt.cancel();
    super.dispose();
  }
}