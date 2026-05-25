import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  bool _isSpeaking = false;
  bool _isPaused = false;
  String _currentLocale = 'en-IN';
  String _lastText = '';
  String? _currentMessageId;

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String? get currentMessageId => _currentMessageId;

  // ── Initialization ───────────────────────────────────────────────────────
  Future<void> initialize() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _isSpeaking = true;
      _isPaused = false;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _isPaused = false;
      _currentMessageId = null;
      notifyListeners();
    });

    _tts.setCancelHandler(() {
      _isSpeaking = false;
      _isPaused = false;
      _currentMessageId = null;
      notifyListeners();
    });

    _tts.setErrorHandler((_) {
      _isSpeaking = false;
      _isPaused = false;
      _currentMessageId = null;
      notifyListeners();
    });

    _tts.setPauseHandler(() {
      _isSpeaking = false;
      _isPaused = true;
      notifyListeners();
    });

    _tts.setContinueHandler(() {
      _isSpeaking = true;
      _isPaused = false;
      notifyListeners();
    });
  }

  // ── Language ─────────────────────────────────────────────────────────────
  Future<void> setLanguage(String bcp47) async {
    if (_currentLocale == bcp47) return;
    await stop();

    final supported = await _isSupported(bcp47);
    final target = supported ? bcp47 : 'en-IN';
    await _tts.setLanguage(target);
    _currentLocale = target;

    if (!supported) {
      debugPrint('[TTS] $bcp47 not available on device → falling back to en-IN');
    }
  }

  Future<bool> _isSupported(String bcp47) async {
    try {
      final langs = await _tts.getLanguages as List<dynamic>?;
      if (langs == null) return false;
      final lc = bcp47.split('-').first.toLowerCase();
      return langs.any((l) {
        final s = l.toString().toLowerCase();
        return s == bcp47.toLowerCase() || s.startsWith(lc);
      });
    } catch (_) {
      return false;
    }
  }

  // ── Playback ─────────────────────────────────────────────────────────────
  Future<void> speak(String text, {String? messageId}) async {
    if (text.trim().isEmpty) return;
    
    // Always stop previous speech first as requested
    await stop();
    
    _lastText = text;
    _currentMessageId = messageId;
    await _tts.speak(text);
  }

  Future<void> pause() async {
    await _tts.pause();
  }

  Future<void> resume() async {
    // If we have a true resume, it should be handled by continueHandler
    // On some platforms flutter_tts resume might just be calling speak again
    if (_isPaused) {
      // For platforms where pause/resume is natively supported
      await _tts.speak(_lastText); 
    } else if (!_isSpeaking) {
      await speak(_lastText, messageId: _currentMessageId);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    _isPaused = false;
    _currentMessageId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
