import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:infant_hearing_app/core/services/audio_service.dart';
import '../domain/boa_models.dart';

/// Specialized Audio Service for BOA Clinical Protocol.
class BoaAudioService {
  final AudioService _coreAudio = AudioService();

  static const String _file45db = 'assets/audio/boa_45db.wav';
  static const String _file70db = 'assets/audio/boa_70db.wav';
  static const String _file90db = 'assets/audio/boa_90db.wav';

  /// Preload BOA assets for seamless clinical testing
  Future<void> preloadAssets() async {
    for (final path in [_file45db, _file70db, _file90db]) {
      try {
        await rootBundle.load(path);
      } catch (e) {
        debugPrint('[BOA CRITICAL] Missing asset: $path — BOA audio will not work.');
      }
    }
    await _coreAudio.preload([_file45db, _file70db, _file90db]);
  }

  Future<void> playStimulus(BoaFrequency frequency, BoaDbLevel dbLevel) async {
    String assetPath;
    switch (dbLevel) {
      case BoaDbLevel.db45: assetPath = _file45db; break;
      case BoaDbLevel.db70: assetPath = _file70db; break;
      case BoaDbLevel.db90: assetPath = _file90db; break;
    }

    debugPrint('BOA Audio: Playing calibrated stimulus for ${dbLevel.label}');
    // Play with retries and max volume (files are pre-calibrated)
    await _coreAudio.playAsset(assetPath, volume: 1.0, retries: 3);
  }

  Future<void> pause() async {
    await _coreAudio.pause();
  }

  Future<void> resume() async {
    await _coreAudio.resume();
  }

  Future<void> playSilentTrial() async {
    debugPrint('BOA Audio: Playing Catch Trial (Silence)');
    await _coreAudio.stop();
  }

  Future<void> stop() async {
    await _coreAudio.stop();
  }
}
