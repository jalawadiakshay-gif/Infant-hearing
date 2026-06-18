import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../domain/boa_models.dart';

/// BOA Audio Service — Clinical-grade stimulus playback.
///
/// KEY FIXES:
/// 1. Own dedicated AudioPlayer (not shared singleton) so disposal is guaranteed.
/// 2. stop() is always called on screen exit via dispose().
/// 3. Stimulus duration is controlled by a Completer tied to the player's
///    onPlayerComplete stream — not a blind Timer that can outlive the audio.
/// 4. No overlapping playback: always stop() before play().
/// 5. Silent catch trials are a genuine pause with the same duration as real trials.
/// 6. FIXED: onLog listener leak — only subscribe once.
/// 7. FIXED: Preload uses setSource once per asset without playing.
class BoaAudioService {
  // Each BoaController instance gets its OWN player — never shared.
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completionSub;
  StreamSubscription<String>? _logSub;
  bool _disposed = false;
  bool _preloaded = false;

  static const String _file45db = 'audio/boa_45db.wav'; // relative to assets/
  static const String _file70db = 'audio/boa_70db.wav';
  static const String _file90db = 'audio/boa_90db.wav';

  /// Stimulus duration per JNMC protocol: 3 seconds.
  static const Duration stimulusDuration = Duration(seconds: 3);

  /// Preload all BOA assets into AudioPlayer cache for zero-latency playback.
  Future<void> preloadAssets() async {
    if (_disposed || _preloaded) return;
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            usageType: AndroidUsageType.media,
            contentType: AndroidContentType.music,
            audioFocus: AndroidAudioFocus.gainTransientExclusive,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.defaultToSpeaker},
          ),
        ),
      );

      // Subscribe to log stream ONCE (not per-play-call)
      _logSub?.cancel();
      _logSub = _player.onLog.listen(
        (msg) => debugPrint('[BoaAudio LOG] $msg'),
      );

      // Warm up each asset by setting source (won't play until play() called)
      for (final path in [_file45db, _file70db, _file90db]) {
        try {
          await _player.setSource(AssetSource(path));
          await _player.stop(); // Reset after warming
          debugPrint('[BoaAudio] Warmed up: $path');
        } catch (e) {
          debugPrint('[BoaAudio] Preload warning for $path: $e');
        }
      }
      _preloaded = true;
      debugPrint('[BoaAudio] All 3 assets preloaded successfully.');
    } catch (e) {
      debugPrint('[BoaAudio] Preload error: $e');
    }
  }

  /// Play the calibrated stimulus for the given dB level.
  /// Returns a Future that completes when the audio finishes OR [stimulusDuration]
  /// elapses — whichever comes first. This prevents the controller from hanging
  /// if the file is corrupt.
  Future<void> playStimulus(BoaFrequency frequency, BoaDbLevel dbLevel) async {
    if (_disposed) return;

    await _stop(); // Guarantee no overlap

    final assetPath = _assetPath(dbLevel);
    debugPrint('[BoaAudio] ▶ Playing ${dbLevel.label} via $assetPath');

    final completer = Completer<void>();

    // Cancel any previous completion listener
    await _completionSub?.cancel();
    _completionSub = _player.onPlayerComplete.listen((_) {
      debugPrint('[BoaAudio] ✓ Playback completed naturally');
      if (!completer.isCompleted) completer.complete();
    });

    try {
      // Always set volume to max for calibrated playback
      await _player.setVolume(1.0);

      // Set source first, then play for reliable sync
      await _player.setSource(AssetSource(assetPath));
      await _player.resume(); // resume after setSource is more reliable than play()

      debugPrint('[BoaAudio] Player state after resume: ${_player.state}');
    } catch (e) {
      debugPrint('[BoaAudio] ✗ Play error: $e');
      if (!completer.isCompleted) completer.complete();
      return;
    }

    // Timeout safety: if file doesn't fire onPlayerComplete, we fall through
    // after stimulusDuration + a 500ms grace period.
    await completer.future.timeout(
      stimulusDuration + const Duration(milliseconds: 500),
      onTimeout: () {
        debugPrint('[BoaAudio] Stimulus duration timeout — stopping.');
      },
    );

    // Always stop cleanly after the stimulus window
    await _stop();
    debugPrint('[BoaAudio] ■ Stimulus cycle complete for ${dbLevel.label}');
  }

  /// Silent catch trial — same duration as real stimulus, but no sound.
  Future<void> playSilentTrial() async {
    if (_disposed) return;
    await _stop();
    debugPrint('[BoaAudio] Catch trial — silence for ${stimulusDuration.inSeconds}s');
    await Future.delayed(stimulusDuration);
  }

  /// Immediately stop playback. Safe to call from dispose().
  Future<void> stop() async {
    await _stop();
  }

  Future<void> _stop() async {
    try {
      await _completionSub?.cancel();
      _completionSub = null;
      await _player.stop();
    } catch (e) {
      debugPrint('[BoaAudio] Stop error (non-fatal): $e');
    }
  }

  String _assetPath(BoaDbLevel level) {
    switch (level) {
      case BoaDbLevel.db45: return _file45db;
      case BoaDbLevel.db70: return _file70db;
      case BoaDbLevel.db90: return _file90db;
    }
  }

  /// Must be called when the BOA screen is disposed.
  Future<void> dispose() async {
    _disposed = true;
    await _stop();
    await _logSub?.cancel();
    _logSub = null;
    await _player.dispose();
  }
}
