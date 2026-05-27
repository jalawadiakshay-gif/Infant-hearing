import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../domain/boa_models.dart';

/// BOA Audio Service — Clinical-grade stimulus playback.
///
/// KEY FIXES over previous implementation:
/// 1. Own dedicated AudioPlayer (not shared singleton) so disposal is guaranteed.
/// 2. stop() is always called on screen exit via dispose().
/// 3. Stimulus duration is controlled by a Completer tied to the player's
///    onPlayerComplete stream — not a blind Timer that can outlive the audio.
/// 4. No overlapping playback: always stop() before play().
/// 5. Silent catch trials are a genuine pause with the same duration as real trials.
class BoaAudioService {
  // Each BoaController instance gets its OWN player — never shared.
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completionSub;
  bool _disposed = false;

  static const String _file45db = 'audio/boa_45db.wav'; // relative to assets/
  static const String _file70db = 'audio/boa_70db.wav';
  static const String _file90db = 'audio/boa_90db.wav';

  /// Stimulus duration per JNMC protocol: 3 seconds.
  static const Duration stimulusDuration = Duration(seconds: 3);

  /// Preload all BOA assets into AudioPlayer cache for zero-latency playback.
  Future<void> preloadAssets() async {
    if (_disposed) return;
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      await _player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            usageType: AndroidUsageType.media,
            contentType: AndroidContentType.music,
            audioFocus: AndroidAudioFocus.gainTransientExclusive,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.defaultToSpeaker},
          ),
        ),
      );

      // Warm up each asset by setting source (won't play until play() called)
      for (final path in [_file45db, _file70db, _file90db]) {
        try {
          await _player.setSource(AssetSource(path));
        } catch (e) {
          debugPrint('[BoaAudio] Preload warning for $path: $e');
        }
      }
      debugPrint('[BoaAudio] Assets preloaded.');
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
    debugPrint('[BoaAudio] Playing ${dbLevel.label} via $assetPath');

    final completer = Completer<void>();

    // Cancel any previous completion listener
    await _completionSub?.cancel();
    _completionSub = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });

    try {
      await _player.setVolume(1.0);
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('[BoaAudio] Play error: $e');
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
    await _player.dispose();
  }
}
