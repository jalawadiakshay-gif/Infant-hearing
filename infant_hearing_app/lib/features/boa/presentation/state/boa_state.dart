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
  
  // ── Production Grade BOA additions ────────────────────────────────────────
  final bool isBabyPresent;
  final double presenceConfidence;
  final bool manualPresenceOverride;
  final bool isCatchTrial;
  final int habituationCount;
  final double baselineMotion;

  const BoaState({
    this.phase = BoaTestPhase.idle,
    this.currentDbLevel = BoaDbLevel.db70,
    this.currentFrequency = BoaFrequency.freq1kHz,
    this.trials = const [],
    this.playbackProgress = 0.0,
    this.outcome,
    this.errorMessage,
    this.isCameraInitialized = false,
    this.lensDirection = CameraLensDirection.front,
    this.isRecording = false,
    this.isAnalyzing = false,
    this.isCooldownActive = false,
    this.aiConfidence = 0.0,
    this.aiDetection = AiDetectionType.none,
    this.isBabyPresent = false,
    this.presenceConfidence = 0.0,
    this.manualPresenceOverride = false,
    this.isCatchTrial = false,
    this.habituationCount = 0,
    this.baselineMotion = 0.0,
  });

  BoaState copyWith({
    BoaTestPhase? phase,
    BoaDbLevel? currentDbLevel,
    BoaFrequency? currentFrequency,
    List<BoaTrial>? trials,
    double? playbackProgress,
    BoaOutcome? outcome,
    String? errorMessage,
    bool? isCameraInitialized,
    CameraLensDirection? lensDirection,
    bool? isRecording,
    bool? isAnalyzing,
    bool? isCooldownActive,
    double? aiConfidence,
    AiDetectionType? aiDetection,
    bool? isBabyPresent,
    double? presenceConfidence,
    bool? manualPresenceOverride,
    bool? isCatchTrial,
    int? habituationCount,
    double? baselineMotion,
  }) {
    return BoaState(
      phase: phase ?? this.phase,
      currentDbLevel: currentDbLevel ?? this.currentDbLevel,
      currentFrequency: currentFrequency ?? this.currentFrequency,
      trials: trials ?? this.trials,
      playbackProgress: playbackProgress ?? this.playbackProgress,
      outcome: outcome ?? this.outcome,
      errorMessage: errorMessage ?? this.errorMessage,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      lensDirection: lensDirection ?? this.lensDirection,
      isRecording: isRecording ?? this.isRecording,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isCooldownActive: isCooldownActive ?? this.isCooldownActive,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiDetection: aiDetection ?? this.aiDetection,
      isBabyPresent: isBabyPresent ?? this.isBabyPresent,
      presenceConfidence: presenceConfidence ?? this.presenceConfidence,
      manualPresenceOverride: manualPresenceOverride ?? this.manualPresenceOverride,
      isCatchTrial: isCatchTrial ?? this.isCatchTrial,
      habituationCount: habituationCount ?? this.habituationCount,
      baselineMotion: baselineMotion ?? this.baselineMotion,
    );
  }

  bool get canRespond => phase == BoaTestPhase.awaitingResponse || phase == BoaTestPhase.playing;
  bool get canPlay => (phase == BoaTestPhase.idle || phase == BoaTestPhase.infantDetection) 
      && isCameraInitialized 
      && !isRecording 
      && !isCooldownActive
      && (isBabyPresent || manualPresenceOverride);
  bool get isComplete => phase == BoaTestPhase.complete;
}
