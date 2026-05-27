import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:infant_hearing_app/shared/repositories/boa_repository.dart';
import 'package:infant_hearing_app/core/services/tts_service.dart';
import '../../domain/boa_models.dart';
import '../state/boa_state.dart';
import '../../services/boa_audio_service.dart';
import '../../services/boa_cv_service.dart';

/// Production-grade BOA Controller.
///
/// KEY FIXES over previous implementation:
///
/// 1. AUDIO LEAK: BoaAudioService now owns its OWN AudioPlayer (not the
///    shared singleton). Dispose() always calls audio.dispose().
///
/// 2. CAMERA LIFECYCLE: stopImageStream() is correctly awaited before
///    dispose(). Mounted checks before every notifyListeners() after async gaps.
///
/// 3. RACE CONDITIONS: A single _isAiBusy mutex + frame throttle at 5fps.
///    Timer cancellation is always done BEFORE starting a new one.
///
/// 4. TEMPORAL SIGNALLING: Controller notifies CvService of stimulus
///    start/end so response detection is gated to the clinical window.
///
/// 5. RESPONSE WINDOW TIMEOUT: Auto-advance to idle after 8 seconds if
///    caregiver doesn't tap — prevents stuck awaitingResponse state.
///
/// 6. COOLDOWN: 2s cooldown between trials, prevents rapid re-triggering.
///
/// 7. HABITUATION GUARD: After 3 consecutive no-responses at same level,
///    the controller warns the clinician.
class BoaController extends ChangeNotifier {
  final BoaRepository? boaRepository;
  final TtsService _ttsService;

  // Each controller owns its own audio + cv instances
  final BoaAudioService _audioService = BoaAudioService();
  final BoaCvService _cvService = BoaCvService();

  BoaState _state = const BoaState();
  bool _disposed = false;

  // ── Timers ─────────────────────────────────────────────────────────────────
  Timer? _progressTimer;        // Drives playbackProgress UI bar
  Timer? _cooldownTimer;
  Timer? _responseWindowTimer;  // Auto-close observation window
  Timer? _preCheckTimer;        // Delayed initialization guard

  // ── Camera ─────────────────────────────────────────────────────────────────
  CameraController? _cameraController;
  bool _isAiBusy = false;
  DateTime _lastFrameTime = DateTime(2000);
  static const Duration _frameThrottle = Duration(milliseconds: 200); // 5fps

  // ── Misc ───────────────────────────────────────────────────────────────────
  final Random _random = Random();

  BoaController({
    this.boaRepository,
    required TtsService ttsService,
  }) : _ttsService = ttsService;

  // ── Public Getters ─────────────────────────────────────────────────────────
  BoaState get state => _state;
  CameraController? get cameraController => _cameraController;

  // ── Initialization ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_disposed) return;
    _cancelAllTimers();
    _cvService.reset();

    _state = const BoaState(
      phase: BoaTestPhase.idle,
      currentDbLevel: BoaDbLevel.db70,
      currentFrequency: BoaFrequency.freq1kHz,
    );
    _safeNotify();

    await _ttsService.initialize();
    await _audioService.preloadAssets();
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_disposed) return;

    // Safely tear down any existing camera
    await _disposeCameraController();

    List<CameraDescription> cameras;
    try {
      cameras = await availableCameras();
    } catch (e) {
      debugPrint('[BoaCtrl] availableCameras() failed: $e');
      _state = _state.copyWith(errorMessage: 'Cannot access camera hardware.');
      _safeNotify();
      return;
    }

    if (cameras.isEmpty) {
      _state = _state.copyWith(errorMessage: 'No camera found on this device.');
      _safeNotify();
      return;
    }

    // Prefer back camera (better for pointing at infant on lap)
    CameraDescription target;
    try {
      target = cameras.firstWhere(
        (c) => c.lensDirection == _state.lensDirection,
        orElse: () => cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        ),
      );
    } catch (_) {
      target = cameras.first;
    }

    _cameraController = CameraController(
      target,
      ResolutionPreset.medium, // Balanced: good enough for face detection, light on RAM
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // Best for MLKit on Android
    );

    try {
      await _cameraController!.initialize();
    } catch (e) {
      debugPrint('[BoaCtrl] Camera init error: $e');
      String msg = 'Camera failed to initialize.';
      if (e is CameraException) {
        if (e.code == 'CameraAccessDenied') msg = 'Camera permission denied. Please allow camera access in Settings.';
      }
      _state = _state.copyWith(errorMessage: msg, isCameraInitialized: false);
      _safeNotify();
      return;
    }

    if (_disposed || _cameraController == null) return;

    _state = _state.copyWith(
      isCameraInitialized: true,
      lensDirection: target.lensDirection,
      clearError: true,
    );
    _safeNotify();

    _startImageStream();
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      _cameraController!.startImageStream(_onCameraFrame);
      _state = _state.copyWith(phase: BoaTestPhase.infantDetection);
      _safeNotify();
    } catch (e) {
      debugPrint('[BoaCtrl] startImageStream error: $e');
    }
  }

  // ── Camera Frame Processing ────────────────────────────────────────────────

  void _onCameraFrame(CameraImage image) async {
    if (_disposed || _isAiBusy) return;

    final now = DateTime.now();
    if (now.difference(_lastFrameTime) < _frameThrottle) return;
    _lastFrameTime = now;

    _isAiBusy = true;
    try {
      final rotation = _getSensorRotation();
      final isActive = _state.phase == BoaTestPhase.playing ||
                       _state.phase == BoaTestPhase.awaitingResponse;

      final result = await _cvService.analyzeFrame(
        image,
        rotation,
        isActiveTrial: isActive,
      );

      if (_disposed) return;
      _state = _state.copyWith(
        isBabyPresent: result.babyPresent,
        presenceConfidence: result.presenceConfidence,
        aiDetection: result.detectionType,
        aiConfidence: result.responseConfidence,
        responseStrength: result.responseStrength,
        baselineMotion: result.motionMetric,
      );
      _safeNotify();
    } catch (e) {
      debugPrint('[BoaCtrl] CV error: $e');
    } finally {
      _isAiBusy = false;
    }
  }

  InputImageRotation _getSensorRotation() {
    final orientation = _cameraController?.description.sensorOrientation ?? 0;
    switch (orientation) {
      case 90:  return InputImageRotation.rotation90deg;
      case 180: return InputImageRotation.rotation180deg;
      case 270: return InputImageRotation.rotation270deg;
      default:  return InputImageRotation.rotation0deg;
    }
  }

  // ── Trial Logic ────────────────────────────────────────────────────────────

  Future<void> startTrial() async {
    if (_disposed || !_state.canStartTrial) return;

    // Habituation check: 3 consecutive no-responses = warn clinician
    if (_state.habituationCount >= 3) {
      _state = _state.copyWith(
        statusOverride: 'Possible habituation. Comfort the baby, then retry.',
      );
      _safeNotify();
      return;
    }

    _cancelProgressTimer();
    _cancelResponseWindowTimer();

    // Determine if catch trial (20% chance, only after first real trial)
    final isCatch = _state.trials.isNotEmpty && _random.nextDouble() < 0.20;

    // Brief calibration pause (1–2.5s random delay — prevents anticipatory response)
    _state = _state.copyWith(
      phase: BoaTestPhase.calibration,
      clearError: true,
      clearStatusOverride: true,
      isCatchTrial: isCatch,
    );
    _safeNotify();

    final delay = 1000 + _random.nextInt(1500);
    await Future.delayed(Duration(milliseconds: delay));

    if (_disposed || _state.phase != BoaTestPhase.calibration) return;

    // Enter playing phase
    _state = _state.copyWith(
      phase: isCatch ? BoaTestPhase.catchTrial : BoaTestPhase.playing,
      playbackProgress: 0.0,
      isRecording: true,
      stimulusStartTime: DateTime.now(),
    );
    _safeNotify();

    // Notify CV service that stimulus is starting
    _cvService.onStimulusStart();

    // Start progress bar timer (3 seconds = 30 ticks at 100ms)
    _startProgressTimer();

    // Play audio — this future completes when audio ends (3s)
    try {
      if (isCatch) {
        await _audioService.playSilentTrial();
      } else {
        await _audioService.playStimulus(_state.currentFrequency, _state.currentDbLevel);
      }
    } catch (e) {
      debugPrint('[BoaCtrl] Audio play error: $e');
    }

    if (_disposed) return;
    _concludeStimulus();
  }

  void _startProgressTimer() {
    _cancelProgressTimer();
    int ticks = 0;
    const totalTicks = 30; // 3 seconds × 10 ticks/s
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_disposed) { timer.cancel(); return; }
      ticks++;
      final progress = (ticks / totalTicks).clamp(0.0, 1.0);
      _state = _state.copyWith(playbackProgress: progress);
      _safeNotify();
      if (ticks >= totalTicks) timer.cancel();
    });
  }

  void _concludeStimulus() {
    _cancelProgressTimer();
    _cvService.onStimulusEnd();

    if (_disposed) return;
    _state = _state.copyWith(
      phase: BoaTestPhase.awaitingResponse,
      isRecording: false,
      playbackProgress: 1.0,
    );
    _safeNotify();

    // Auto-timeout: if caregiver doesn't respond in 8 seconds, return to idle
    _cancelResponseWindowTimer();
    _responseWindowTimer = Timer(const Duration(seconds: 8), () {
      if (_disposed) return;
      if (_state.phase == BoaTestPhase.awaitingResponse) {
        debugPrint('[BoaCtrl] Response window timed out. Auto-advancing to idle.');
        _cvService.onResponseWindowClose();
        _state = _state.copyWith(
          phase: BoaTestPhase.idle,
          isRecording: false,
          clearStimulusTime: true,
          statusOverride: 'No response recorded. Tap to try again.',
        );
        _startCooldown();
        _safeNotify();
      }
    });
  }

  void recordResponse(BoaResponse response) {
    if (_disposed || !_state.canRespond) return;

    _cancelResponseWindowTimer();
    _cvService.onResponseWindowClose();

    final trial = BoaTrial(
      dbLevel: _state.currentDbLevel,
      frequency: _state.currentFrequency,
      response: response,
      timestamp: DateTime.now(),
      isCatchTrial: _state.isCatchTrial,
      aiConfidence: _state.aiConfidence,
      aiDetection: _state.aiDetection,
    );

    final updatedTrials = [..._state.trials, trial];
    final newHabCount = (response == BoaResponse.noResponse)
        ? _state.habituationCount + 1
        : 0;

    BoaTestPhase nextPhase = BoaTestPhase.idle;
    BoaDbLevel nextDb = _state.currentDbLevel;
    BoaOutcome? finalOutcome = _state.outcome;

    if (_state.isCatchTrial) {
      // Catch trial: just record, don't advance protocol
      nextPhase = BoaTestPhase.idle;
    } else {
      // Adaptive protocol: 70 → 45 or 90
      switch (_state.currentDbLevel) {
        case BoaDbLevel.db70:
          nextDb = (response == BoaResponse.responseDetected) ? BoaDbLevel.db45 : BoaDbLevel.db90;
          nextPhase = BoaTestPhase.idle;
          break;
        case BoaDbLevel.db45:
        case BoaDbLevel.db90:
          // Second level — test complete
          final isDb45 = _state.currentDbLevel == BoaDbLevel.db45;
          if (response == BoaResponse.responseDetected) {
            finalOutcome = isDb45
                ? BoaOutcome.favorableHearingResponse
                : BoaOutcome.monitor;
          } else {
            finalOutcome = isDb45
                ? BoaOutcome.monitor
                : BoaOutcome.suspectedHearingLoss;
          }
          nextPhase = BoaTestPhase.complete;
          break;
      }
    }

    _state = _state.copyWith(
      trials: updatedTrials,
      phase: nextPhase,
      currentDbLevel: nextDb,
      outcome: finalOutcome,
      isCatchTrial: false,
      habituationCount: newHabCount,
      isRecording: false,
      clearStimulusTime: true,
      clearStatusOverride: true,
      aiDetection: AiDetectionType.none,
      aiConfidence: 0.0,
    );

    if (nextPhase == BoaTestPhase.idle) {
      _startCooldown();
    }

    _safeNotify();
  }

  void _startCooldown() {
    _cancelCooldownTimer();
    _state = _state.copyWith(isCooldownActive: true);
    _cooldownTimer = Timer(const Duration(seconds: 2), () {
      if (_disposed) return;
      _state = _state.copyWith(isCooldownActive: false);
      _safeNotify();
    });
  }

  // ── Manual overrides ───────────────────────────────────────────────────────

  void setManualPresenceOverride(bool value) {
    _state = _state.copyWith(manualPresenceOverride: value);
    _safeNotify();
  }

  // ── Camera flip ────────────────────────────────────────────────────────────

  Future<void> toggleCamera() async {
    final newDir = (_state.lensDirection == CameraLensDirection.front)
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    _state = _state.copyWith(lensDirection: newDir, isCameraInitialized: false);
    _safeNotify();
    await _initializeCamera();
  }

  // ── Submit & Reset ─────────────────────────────────────────────────────────

  Future<void> submitResult() async {
    if (_state.outcome == null || boaRepository == null) return;
    try {
      await boaRepository!.submitResult({
        'outcome': _state.outcome.toString(),
        'trials': _state.trials.map((t) => {
          'level': t.dbLevel.label,
          'frequency': t.frequency.label,
          'response': t.response.label,
          'isCatchTrial': t.isCatchTrial,
          'aiConfidence': t.aiConfidence,
        }).toList(),
      });
    } catch (e) {
      debugPrint('[BoaCtrl] submitResult error: $e');
    }
  }

  void reset() {
    _cancelAllTimers();
    _cvService.reset();
    _audioService.stop();
    _state = const BoaState();
    _safeNotify();
    // Reinitialize everything
    initialize();
  }

  // ── App lifecycle (called from screen's WidgetsBindingObserver) ─────────────

  Future<void> onAppPaused() async {
    await _audioService.stop(); // Critical: stop audio when app goes background
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      try { await _cameraController!.stopImageStream(); } catch (_) {}
    }
    if (_state.phase == BoaTestPhase.playing ||
        _state.phase == BoaTestPhase.awaitingResponse ||
        _state.phase == BoaTestPhase.catchTrial) {
      _cancelAllTimers();
      _state = _state.copyWith(
        phase: BoaTestPhase.idle,
        isRecording: false,
        clearStimulusTime: true,
      );
      _safeNotify();
    }
  }

  Future<void> onAppResumed() async {
    if (!_state.isCameraInitialized) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!_disposed) await _initializeCamera();
    } else {
      // Restart image stream if it was stopped
      _startImageStream();
    }
  }

  // ── Resources ──────────────────────────────────────────────────────────────

  Future<void> releaseResources() async {
    _cancelAllTimers();
    await _audioService.stop();
    await _disposeCameraController();
    _cvService.reset();
    _state = _state.copyWith(isCameraInitialized: false, isRecording: false);
    _safeNotify();
  }

  Future<void> _disposeCameraController() async {
    final cam = _cameraController;
    _cameraController = null;
    if (cam != null) {
      if (cam.value.isStreamingImages) {
        try { await cam.stopImageStream(); } catch (_) {}
      }
      try { await cam.dispose(); } catch (_) {}
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelAllTimers();
    _audioService.dispose(); // This owns its player — dispose stops audio
    _cvService.dispose();

    final cam = _cameraController;
    _cameraController = null;
    if (cam != null) {
      cam.stopImageStream().catchError((_) {}).then((_) => cam.dispose());
    }
    super.dispose();
  }

  // ── Timer helpers ──────────────────────────────────────────────────────────

  void _cancelAllTimers() {
    _cancelProgressTimer();
    _cancelCooldownTimer();
    _cancelResponseWindowTimer();
    _preCheckTimer?.cancel();
    _preCheckTimer = null;
  }

  void _cancelProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  void _cancelCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  void _cancelResponseWindowTimer() {
    _responseWindowTimer?.cancel();
    _responseWindowTimer = null;
  }

  // ── Safe notify ────────────────────────────────────────────────────────────

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }
}
