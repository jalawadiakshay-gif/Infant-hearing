import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Production-grade Audio Service.
/// Optimized for zero-latency clinical stimuli playback.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, Source> _cache = {};
  bool _isInitialized = false;

  AudioService._internal() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.setPlayerMode(PlayerMode.lowLatency); // Optimize for zero-latency
    
    await _audioPlayer.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          usageType: AndroidUsageType.media,
          contentType: AndroidContentType.music,
          audioFocus: AndroidAudioFocus.gainTransientExclusive, // Exclusive focus for clinical accuracy
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
      ),
    );
    _isInitialized = true;
  }

  /// Preload assets into memory for zero-latency playback
  Future<void> preload(List<String> assetPaths) async {
    await _initialize();
    for (final path in assetPaths) {
      if (!_cache.containsKey(path)) {
        final cleanPath = path.startsWith('assets/') ? path.replaceFirst('assets/', '') : path;
        final source = AssetSource(cleanPath);
        _cache[path] = source;
        // Audioplayers 6+ doesn't have a direct "load" on the source, 
        // but we can set the source to the player once to warm it up
        try {
          await _audioPlayer.setSource(source);
        } catch (e) {
          debugPrint('AudioService Preload Warning: $e');
        }
      }
    }
  }

  Future<void> playAsset(String assetPath, {double volume = 1.0, int retries = 2}) async {
    try {
      if (!_isInitialized) await _initialize();
      
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(volume);

      Source? source = _cache[assetPath];
      if (source == null) {
        final cleanPath = assetPath.startsWith('assets/') ? assetPath.replaceFirst('assets/', '') : assetPath;
        source = AssetSource(cleanPath);
        _cache[assetPath] = source;
      }

      await _audioPlayer.play(source);
      debugPrint('AudioService: Playing $assetPath');
    } catch (e) {
      debugPrint('AudioService Error: $e');
      if (retries > 0) {
        debugPrint('AudioService: Retrying... ($retries left)');
        await Future.delayed(const Duration(milliseconds: 300));
        return playAsset(assetPath, volume: volume, retries: retries - 1);
      }
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('AudioService stop error: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
