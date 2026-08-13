import 'package:camera/camera.dart';
import '../../domain/boa_models.dart';

/// Immutable snapshot of the BOA test at any point in time.
class BoaState {
  final BoaTestPhase phase;
  final BoaDbLevel currentDbLevel;
  final BoaFrequency currentFrequency;
  final List<BoaTrial> trials;
  final double playbackProgress;
  final BoaOutcome? outcome;
  final String? errorMessage;

  // ── Camera & AI State ──────────────────────────────────────────────────────
  final bool isCameraInitialized;
  final CameraLensDirection lensDirection;
  final bool isRecording;
  final bool isAnalyzing;
  final bool isCooldownActive;
  final double aiConfidence;
  final AiDetectionType aiDetection;
  final ResponseStrength responseStrength;

  // ── Production-grade additions ─────────────────────────────────────────────
  final bool isBabyPresent;
  final double presenceConfidence;
  final bool manualPresenceOverride;
  final bool isCatchTrial;
  final int habituationCount;
  final double baselineMotion;
  final double noiseLevel;       // Env noise floor (0-100 scale)
  final double testReliability;  // Calculated index (0-1.0)

  /// Timestamp when stimulus playback began — used for temporal response window.
  final DateTime? stimulusStartTime;

  /// Current dB level text for display. Can override with temporary messages.
  final String? statusOverride;

  // ── Enhanced CV fields ─────────────────────────────────────────────────────
  final double poseConfidence;
  final List<AiDetectionType> detectedBehaviors;
  final String? cvExplanation;
  final int? responseLatencyMs;

  // ── NEW: UX + Recording fields ─────────────────────────────────────────────

  /// Countdown in seconds during awaitingResponse phase (8 → 0).
  final int remainingResponseSeconds;

  /// The current clinical trial number (1-indexed, excludes catch trials).
  final int trialNumber;

  /// Path to the locally saved video file for this session.
  final String? localVideoPath;

  /// Qualitative quality of the current CV frame pipeline.
  final CvFrameQuality cvFrameQuality;

  const BoaState({
    this.phase = BoaTestPhase.idle,
    this.currentDbLevel = BoaDbLevel.db70,
    this.currentFrequency = BoaFrequency.freq1kHz,
    this.trials = const [],
    this.playbackProgress = 0.0,
    this.outcome,
    this.errorMessage,
    this.isCameraInitialized = false,
    this.lensDirection = CameraLensDirection.back,
    this.isRecording = false,
    this.isAnalyzing = false,
    this.isCooldownActive = false,
    this.aiConfidence = 0.0,
    this.aiDetection = AiDetectionType.none,
    this.responseStrength = ResponseStrength.none,
    this.isBabyPresent = false,
    this.presenceConfidence = 0.0,
    this.manualPresenceOverride = false,
    this.isCatchTrial = false,
    this.habituationCount = 0,
    this.baselineMotion = 0.0,
    this.noiseLevel = 0.0,
    this.testReliability = 1.0,
    this.stimulusStartTime,
    this.statusOverride,
    this.poseConfidence = 0.0,
    this.detectedBehaviors = const [],
    this.cvExplanation,
    this.responseLatencyMs,
    this.remainingResponseSeconds = 0,
    this.trialNumber = 0,
    this.localVideoPath,
    this.cvFrameQuality = CvFrameQuality.unknown,
  });

  BoaState copyWith({
    BoaTestPhase? phase,
    BoaDbLevel? currentDbLevel,
    BoaFrequency? currentFrequency,
    List<BoaTrial>? trials,
    double? playbackProgress,
    BoaOutcome? outcome,
    String? errorMessage,
    bool clearError = false,
    bool? isCameraInitialized,
    CameraLensDirection? lensDirection,
    bool? isRecording,
    bool? isAnalyzing,
    bool? isCooldownActive,
    double? aiConfidence,
    AiDetectionType? aiDetection,
    ResponseStrength? responseStrength,
    bool? isBabyPresent,
    double? presenceConfidence,
    bool? manualPresenceOverride,
    bool? isCatchTrial,
    int? habituationCount,
    double? baselineMotion,
    double? noiseLevel,
    double? testReliability,
    DateTime? stimulusStartTime,
    bool clearStimulusTime = false,
    String? statusOverride,
    bool clearStatusOverride = false,
    double? poseConfidence,
    List<AiDetectionType>? detectedBehaviors,
    String? cvExplanation,
    bool clearCvExplanation = false,
    int? responseLatencyMs,
    int? remainingResponseSeconds,
    int? trialNumber,
    String? localVideoPath,
    CvFrameQuality? cvFrameQuality,
  }) {
    return BoaState(
      phase: phase ?? this.phase,
      currentDbLevel: currentDbLevel ?? this.currentDbLevel,
      currentFrequency: currentFrequency ?? this.currentFrequency,
      trials: trials ?? this.trials,
      playbackProgress: playbackProgress ?? this.playbackProgress,
      outcome: outcome ?? this.outcome,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      lensDirection: lensDirection ?? this.lensDirection,
      isRecording: isRecording ?? this.isRecording,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isCooldownActive: isCooldownActive ?? this.isCooldownActive,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiDetection: aiDetection ?? this.aiDetection,
      responseStrength: responseStrength ?? this.responseStrength,
      isBabyPresent: isBabyPresent ?? this.isBabyPresent,
      presenceConfidence: presenceConfidence ?? this.presenceConfidence,
      manualPresenceOverride: manualPresenceOverride ?? this.manualPresenceOverride,
      isCatchTrial: isCatchTrial ?? this.isCatchTrial,
      habituationCount: habituationCount ?? this.habituationCount,
      baselineMotion: baselineMotion ?? this.baselineMotion,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      testReliability: testReliability ?? this.testReliability,
      stimulusStartTime: clearStimulusTime ? null : (stimulusStartTime ?? this.stimulusStartTime),
      statusOverride: clearStatusOverride ? null : (statusOverride ?? this.statusOverride),
      poseConfidence: poseConfidence ?? this.poseConfidence,
      detectedBehaviors: detectedBehaviors ?? this.detectedBehaviors,
      cvExplanation: clearCvExplanation ? null : (cvExplanation ?? this.cvExplanation),
      responseLatencyMs: responseLatencyMs ?? this.responseLatencyMs,
      remainingResponseSeconds: remainingResponseSeconds ?? this.remainingResponseSeconds,
      trialNumber: trialNumber ?? this.trialNumber,
      localVideoPath: localVideoPath ?? this.localVideoPath,
      cvFrameQuality: cvFrameQuality ?? this.cvFrameQuality,
    );
  }

  // ── Computed convenience getters ───────────────────────────────────────────

  bool get canRespond =>
      phase == BoaTestPhase.awaitingResponse || phase == BoaTestPhase.playing;

  bool get canStartTrial =>
      (phase == BoaTestPhase.idle || phase == BoaTestPhase.infantDetection) &&
      isCameraInitialized &&
      !isRecording &&
      !isCooldownActive &&
      (isBabyPresent || manualPresenceOverride);

  bool get isComplete => phase == BoaTestPhase.complete;

  bool get isPlaying =>
      phase == BoaTestPhase.playing || phase == BoaTestPhase.catchTrial;

  /// True if we are within the clinical response observation window.
  bool get inResponseWindow {
    if (stimulusStartTime == null) return false;
    final elapsed = DateTime.now().difference(stimulusStartTime!).inMilliseconds;
    // JNMC: response expected within 300ms – 3000ms of stimulus onset
    return elapsed >= 100 && elapsed <= 3000;
  }

  int get totalClinicalTrials => trials.where((t) => !t.isCatchTrial).length;
  int get catchTrialCount => trials.where((t) => t.isCatchTrial).length;
  int get falsePositiveCount =>
      trials.where((t) => t.isCatchTrial && t.response == BoaResponse.responseDetected).length;
}

/// Quality level of the current CV frame pipeline.
enum CvFrameQuality {
  unknown, // Not yet determined
  poor,    // Low brightness or face not found
  marginal, // Face visible but small/partially occluded
  good,    // Good face visibility, calibrated baseline
}

extension CvFrameQualityX on CvFrameQuality {
  String get label {
    switch (this) {
      case CvFrameQuality.unknown:  return 'Initializing...';
      case CvFrameQuality.poor:     return 'Poor — Move Closer';
      case CvFrameQuality.marginal: return 'Marginal — Adjust';
      case CvFrameQuality.good:     return 'Good';
    }
  }
}
