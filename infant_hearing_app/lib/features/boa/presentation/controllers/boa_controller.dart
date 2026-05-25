import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:infant_hearing_app/shared/repositories/boa_repository.dart';
import 'package:infant_hearing_app/core/services/tts_service.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import '../../domain/boa_models.dart';
import '../state/boa_state.dart';
import '../../services/boa_audio_service.dart';
import '../../services/boa_cv_service.dart';

/// Production-grade BOA Controller.
/// Manages high-fidelity audio, 2-stage CV pipeline, and adaptive clinical state machine.
class BoaController extends ChangeNotifier {
  final BoaRepository? boaRepository;
  final TtsService _ttsService;
  final BoaAudioService _audioService = BoaAudioService();
  final BoaCvService _cvService = BoaCvService();

  BoaState _state = const BoaState();
  Timer? _playbackTimer;
  Timer? _analysisTimer;
  
  CameraController? _cameraController;
  bool _isAiBusy = false;
  final Random _random = Random();

  DateTime _lastFrameProcessed = DateTime(2000);
  static const Duration _frameThrottle = Duration(milliseconds: 200); // 5fps for CV

  BoaController({this.boaRepository, required TtsService ttsService}) : _ttsService = ttsService;

  BoaState get state => _state;
  CameraController? get cameraController => _cameraController;

  // ── Initialization ───────────────────────────────────────────────────────
  
  Future<void> initialize() async {
    _state = _state.copyWith(
      phase: BoaTestPhase.idle,
      currentDbLevel: BoaDbLevel.db70,
      trials: [],
      errorMessage: null,
      aiDetection: AiDetectionType.none,
      isBabyPresent: false,
      manualPresenceOverride: false,
      habituationCount: 0,
    );

    await _ttsService.initialize();
    await _audioService.preloadAssets();
    await _initializeCamera();
    notifyListeners();
  }

  Future<void> pausePlayback() async {
    await _audioService.pause();
    _playbackTimer?.cancel(); // Simple pause: stop timer and resume with new one
    notifyListeners();
  }

  Future<void> resumePlayback() async {
    await _audioService.resume();
    _startTimerFrom(_state.playbackProgress);
    notifyListeners();
  }

  void _startTimerFrom(double startProgress) {
    int currentTicks = (startProgress * 30).toInt();
    const int totalTicks = 30;
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentTicks++;
      _state = _state.copyWith(playbackProgress: currentTicks / totalTicks);
      if (currentTicks >= totalTicks) {
        timer.cancel();
        _concludeStimulus();
      }
      notifyListeners();
    });
  }

  Future<void> _initializeCamera() async {
    try {
      // 1. Dispose existing if any
      if (_cameraController != null) {
        try { await _cameraController!.stopImageStream(); } catch (_) {}
        await _cameraController!.dispose();
        _cameraController = null;
      }

      // 2. Fetch available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _state = _state.copyWith(errorMessage: 'No camera hardware found on this device.');
        notifyListeners();
        return;
      }

      // 3. Selection Logic (Prioritize requested lens, then fallback)
      CameraDescription target;
      try {
        target = cameras.firstWhere(
          (c) => c.lensDirection == _state.lensDirection,
          orElse: () => cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back, // Primary clinical preference
            orElse: () => cameras.first,
          ),
        );
      } catch (e) {
        target = cameras.first;
      }

      // 4. Initialization with conservative presets for low-end device compatibility
      _cameraController = CameraController(
        target,
        ResolutionPreset.medium, // Balanced for CV and display
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, // Best for Android/MLKit
      );

      await _cameraController!.initialize();
      
      if (_cameraController == null) return; // Disposed during await

      _state = _state.copyWith(
        isCameraInitialized: true, 
        lensDirection: target.lensDirection,
        errorMessage: null,
      );
      
      // 5. Start Presence Detection Loop
      _startPresenceDetection();
    } catch (e) {
      debugPrint('[BoaController] Camera Init Error: $e');
      String msg = 'Camera failed to initialize.';
      if (e is CameraException) {
        if (e.code == 'CameraAccessDenied') msg = 'Camera access denied.';
        else if (e.code == 'AudioAccessDenied') msg = 'Audio access denied.';
      }
      _state = _state.copyWith(isCameraInitialized: false, errorMessage: msg);
    }
    notifyListeners();
  }

  void _startPresenceDetection() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    // Image stream handles all frame analysis at camera frame rate
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        _cameraController!.startImageStream(_processCameraImage);
      } catch (e) {
        debugPrint('[BoaController] Image stream start error: $e');
      }
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isAiBusy) return;

    // Throttle to 5fps to avoid thermal/CPU overload on low-end devices
    final now = DateTime.now();
    if (now.difference(_lastFrameProcessed) < _frameThrottle) return;
    _lastFrameProcessed = now;

    _isAiBusy = true;

    try {
      final rotation = _getRotation();
      final result = await _cvService.analyzeFrame(image, rotation);

      _state = _state.copyWith(
        isBabyPresent: result.babyPresent,
        presenceConfidence: result.presenceConfidence,
        aiDetection: result.detectionType,
        aiConfidence: result.responseConfidence,
        baselineMotion: result.motionMetric,
      );
      
      // If we are playing and a response is detected by AI, we can flag it
      if (_state.phase == BoaTestPhase.playing && result.responseConfidence > 0.8) {
        // Auto-detect response if confidence is very high
        // but clinical protocol usually requires human confirmation.
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('CV Error: $e');
    } finally {
      _isAiBusy = false;
    }
  }

  InputImageRotation _getRotation() {
    final sensorOrientation = _cameraController!.description.sensorOrientation;
    switch (sensorOrientation) {
      case 90: return InputImageRotation.rotation90deg;
      case 180: return InputImageRotation.rotation180deg;
      case 270: return InputImageRotation.rotation270deg;
      default: return InputImageRotation.rotation0deg;
    }
  }

  // ── Test Logic ───────────────────────────────────────────────────────────

  Future<void> startTrial() async {
    if (!_state.canPlay) return;

    // Habituation check
    if (_state.habituationCount >= 3) {
      _state = _state.copyWith(errorMessage: "Possible habituation. Please pause and comfort the baby.");
      notifyListeners();
      return;
    }

    _state = _state.copyWith(
      phase: BoaTestPhase.calibration, // Brief pause for clinician to prepare
      errorMessage: null,
    );
    notifyListeners();

    // Clinical Protocol: Random delay (1-3 seconds) to prevent anticipatory response
    final randomDelay = 1000 + _random.nextInt(2000);
    await Future.delayed(Duration(milliseconds: randomDelay));

    if (_state.phase != BoaTestPhase.calibration) return; // User might have exited

    // Determine if this should be a Catch Trial (20% chance)
    bool isCatch = _random.nextDouble() < 0.2 && _state.trials.isNotEmpty;

    _state = _state.copyWith(
      phase: isCatch ? BoaTestPhase.catchTrial : BoaTestPhase.playing,
      playbackProgress: 0.0,
      isRecording: true,
      isCatchTrial: isCatch,
    );
    notifyListeners();

    try {
      if (isCatch) {
        debugPrint('BOA: Starting Catch Trial (Silence)');
        await _audioService.playSilentTrial();
      } else {
        debugPrint('BOA: Starting Stimulus Trial');
        await _audioService.playStimulus(_state.currentFrequency, _state.currentDbLevel);
      }

      _startTimerFrom(0.0);
    } catch (e) {
      _state = _state.copyWith(errorMessage: "Audio playback failed.", phase: BoaTestPhase.idle);
      _concludeStimulus();
    }
  }

  void _concludeStimulus() {
    _audioService.stop();
    _playbackTimer?.cancel();
    
    // Clinical: Enter observation window
    _state = _state.copyWith(
      phase: BoaTestPhase.awaitingResponse,
      isRecording: false,
    );
    notifyListeners();
    
    // Auto-timeout if clinician doesn't respond in 10 seconds
    Timer(const Duration(seconds: 10), () {
      if (_state.phase == BoaTestPhase.awaitingResponse) {
        // We don't auto-record 'no response' because that's a clinical decision,
        // but we might want to alert the user.
      }
    });
  }

  void setManualPresenceOverride(bool value) {
    _state = _state.copyWith(manualPresenceOverride: value);
    notifyListeners();
  }

  void recordResponse(BoaResponse response) {
    if (!_state.canRespond) return;

    final trial = BoaTrial(
      dbLevel: _state.currentDbLevel,
      frequency: _state.currentFrequency,
      response: response,
      timestamp: DateTime.now(),
      isCatchTrial: _state.isCatchTrial,
    );

    final updatedTrials = [..._state.trials, trial];
    
    // Update Habituation (reset if response detected, increment if no response)
    int newHabCount = (response == BoaResponse.noResponse) ? _state.habituationCount + 1 : 0;

    BoaTestPhase nextPhase = BoaTestPhase.idle;
    BoaDbLevel nextDb = _state.currentDbLevel;
    BoaOutcome? finalOutcome = _state.outcome;

    if (_state.isCatchTrial) {
      // Catch trial doesn't advance protocol, just reset to idle
      nextPhase = BoaTestPhase.idle;
    } else {
      // Adaptive Protocol (70 -> 45/90)
      if (_state.currentDbLevel == BoaDbLevel.db70) {
        if (response == BoaResponse.responseDetected) {
          nextDb = BoaDbLevel.db45;
          nextPhase = BoaTestPhase.idle;
        } else {
          nextDb = BoaDbLevel.db90;
          nextPhase = BoaTestPhase.idle;
        }
      } else {
        // Test Complete
        final isDb45 = _state.currentDbLevel == BoaDbLevel.db45;
        if (response == BoaResponse.responseDetected) {
          finalOutcome = isDb45 ? BoaOutcome.favorableHearingResponse : BoaOutcome.monitor;
        } else {
          finalOutcome = isDb45 ? BoaOutcome.monitor : BoaOutcome.suspectedHearingLoss;
        }
        nextPhase = BoaTestPhase.complete;
      }
    }

    _state = _state.copyWith(
      trials: updatedTrials, 
      phase: nextPhase, 
      currentDbLevel: nextDb,
      outcome: finalOutcome,
      isCatchTrial: false,
      habituationCount: newHabCount,
    );

    // Cooldown logic: Force a small wait before the next trial can start
    if (nextPhase == BoaTestPhase.idle) {
      _startCooldown();
    }
    
    notifyListeners();
  }

  void _startCooldown() {
    // Prevent immediate re-play for 2 seconds to allow baby to settle
    _state = _state.copyWith(isCooldownActive: true); 
    Timer(const Duration(seconds: 2), () {
      _state = _state.copyWith(isCooldownActive: false);
      notifyListeners();
    });
  }

  Future<void> submitResult() async {
    if (_state.outcome == null || boaRepository == null) return;
    try { 
      await boaRepository!.submitResult({
        'outcome': _state.outcome.toString(), 
        'trials': _state.trials.map((t) => t.dbLevel.label).toList()
      }); 
    } catch (_) {}
  }

  void reset() {
    releaseResources().then((_) => initialize());
  }

  // ── Localization & Narration ─────────────────────────────────────────────

  Future<void> speakInstruction(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    
    await _ttsService.setLanguage(locale);
    
    String text = "";
    switch (_state.phase) {
      case BoaTestPhase.idle:
        text = l10n.boaNarrationIntro;
        break;
      case BoaTestPhase.playing:
        text = l10n.boaNarrationPlaying;
        break;
      case BoaTestPhase.awaitingResponse:
        text = l10n.boaNarrationResponse;
        break;
      case BoaTestPhase.infantDetection:
        if (!_state.isBabyPresent) {
          text = l10n.boaNarrationNoInfant;
        }
        break;
      default:
        break;
    }
    
    if (text.isNotEmpty) {
      await _ttsService.speak(text);
    }
  }

  // ── Resources ────────────────────────────────────────────────────────────

  Future<void> toggleCamera() async {
    final newDirection = (_state.lensDirection == CameraLensDirection.front)
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    _state = _state.copyWith(lensDirection: newDirection, isCameraInitialized: false);
    notifyListeners();
    await _initializeCamera();
  }

  Future<void> releaseResources() async {
    _playbackTimer?.cancel();
    _analysisTimer?.cancel();
    await _audioService.stop();
    if (_cameraController != null) {
      try { await _cameraController!.stopImageStream(); } catch (_) {}
      await _cameraController!.dispose();
      _cameraController = null;
    }
    _cvService.reset();
    _state = _state.copyWith(isCameraInitialized: false, isRecording: false);
    notifyListeners();
  }

  @override
  void dispose() {
    // Fire-and-forget but correctly sequenced using unawaited pattern
    // We cannot await in dispose(), so we schedule cleanup and call super last
    _playbackTimer?.cancel();
    _analysisTimer?.cancel();
    _audioService.stop();

    if (_cameraController != null) {
      final cam = _cameraController!;
      _cameraController = null;
      cam.stopImageStream().catchError((_) {}).then((_) => cam.dispose());
    }
    _cvService.dispose();
    super.dispose();
  }
}
