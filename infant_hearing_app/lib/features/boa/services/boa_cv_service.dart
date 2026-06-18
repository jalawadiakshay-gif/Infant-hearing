import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../domain/boa_models.dart';

/// CV Analysis Result — enhanced with dual-pipeline outputs.
class CvAnalysisResult {
  final bool babyPresent;
  final double presenceConfidence;
  final AiDetectionType detectionType;
  final double responseConfidence;
  final ResponseStrength responseStrength;
  final double motionMetric;
  final bool isWithinResponseWindow;
  final double brightness;

  // ── Enhanced CV fields ─────────────────────────────────────────────────────
  final double poseConfidence;
  final List<AiDetectionType> detectedBehaviors;
  final CvExplanation explanation;
  final CvSignalScores signalScores;
  final int? responseLatencyMs;

  CvAnalysisResult({
    required this.babyPresent,
    required this.presenceConfidence,
    required this.detectionType,
    required this.responseConfidence,
    this.responseStrength = ResponseStrength.none,
    this.motionMetric = 0.0,
    this.isWithinResponseWindow = false,
    this.brightness = 128.0,
    this.poseConfidence = 0.0,
    this.detectedBehaviors = const [],
    CvExplanation? explanation,
    this.signalScores = const CvSignalScores(),
    this.responseLatencyMs,
  }) : explanation = explanation ?? CvExplanation.empty();

  static CvAnalysisResult empty() => CvAnalysisResult(
    babyPresent: false,
    presenceConfidence: 0,
    detectionType: AiDetectionType.none,
    responseConfidence: 0,
  );
}

/// Per-feature baseline tracking for pre/post stimulus comparison.
class _FeatureBaseline {
  double headY = 0.0;
  double headX = 0.0;
  double headYVariance = 0.0;
  double eyeOpenness = 0.5;
  double eyeOpennessVariance = 0.0;
  double overallMotion = 0.0;
  double armExtension = 0.0;
  bool isCalibrated = false;
  int calibrationFrames = 0;
}

/// Production-grade Dual-Pipeline CV Service for BOA.
///
/// ARCHITECTURE:
///
///   Pipeline A: Google MLKit FaceDetector
///     → Face bounding box, Euler angles, eye probability
///     → Used for: head turn, eye change, presence validation
///
///   Pipeline B: Google MLKit PoseDetector (MediaPipe Pose)
///     → 33-point body skeleton with world coordinates
///     → Used for: body movement, Moro reflex, freezing, alerting
///
/// KEY IMPROVEMENTS (v2):
///
/// 1. MUCH LOWER THRESHOLDS: Tuned for real-world infant detection where faces
///    are small, movements are subtle, and lighting varies.
///
/// 2. SERIAL PIPELINE EXECUTION: Face + Pose run sequentially, not in parallel,
///    preventing memory pressure crashes on mid-range Android devices.
///
/// 3. ADAPTIVE BASELINES: Baseline recalibrates with running averages, not just
///    one-shot. Variance tracking enables per-infant adaptive thresholds.
///
/// 4. ENHANCED EYE TRACKING: Face detector now uses enableLandmarks for more
///    accurate eye tracking. Eye blink detection uses rate-of-change, not just delta.
///
/// 5. FASTER BASELINE: Calibrates after just 8 frames (~2 seconds) instead of 15.
///
/// 6. RELAXED PRESENCE: Presence confidence threshold lowered from 0.70 to 0.40.
///    Infant faces at arm's length are typically only 3-5% of frame area.
///
/// 7. TEMPORAL GATING with wider window (150ms–3500ms post-stimulus).
///
/// 8. CAMERA SHAKE threshold raised to reduce false rejections.
class BoaCvService {
  // ── Pipeline A: Face Detection ─────────────────────────────────────────────
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,   // Eye open probability
      enableLandmarks: true,        // CHANGED: Enable for better eye tracking
      enableTracking: true,         // ADDED: Track face across frames
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.05,            // LOWERED from 0.08: detect smaller infant faces
    ),
  );

  // ── Pipeline B: Pose Detection ─────────────────────────────────────────────
  PoseDetector? _poseDetector;
  bool _poseEnabled = true;

  // ── Age-adaptive scoring ───────────────────────────────────────────────────
  BoaInfantAgeGroup _ageGroup = BoaInfantAgeGroup.earlyInfant;

  // ── Temporal buffers ───────────────────────────────────────────────────────
  static const int _bufferSize = 20;      // ~4 seconds at 5fps
  static const int _baselineSize = 8;     // REDUCED from 15: faster calibration (~2s)

  final List<double> _motionBuffer = [];
  final List<double> _eyeOpennessBuffer = [];
  final List<Rect> _bboxBuffer = [];
  final List<double> _headYBuffer = [];
  final List<double> _headXBuffer = [];

  // ── Eye blink rate-of-change tracking ──────────────────────────────────────
  final List<double> _eyeRocBuffer = [];   // Rate of change per frame

  // ── Pose-specific buffers ──────────────────────────────────────────────────
  final List<double> _armExtensionBuffer = [];
  final List<double> _bodyMotionBuffer = [];
  final List<Map<PoseLandmarkType, PoseLandmark>> _poseHistory = [];

  // ── Baselines ──────────────────────────────────────────────────────────────
  final _FeatureBaseline _baseline = _FeatureBaseline();

  // ── Stimulus timing ────────────────────────────────────────────────────────
  DateTime? _stimulusStartTime;
  bool _isInResponseWindow = false;
  double _preStimMotion = 0.0;
  double _preStimEyeOpenness = 0.5;
  double _preStimArmExtension = 0.0;

  // ── Brightness tracking ────────────────────────────────────────────────────
  double _lastBrightness = 128.0;

  // ── Sleeping/crying detection ──────────────────────────────────────────────
  int _lowMotionFrameCount = 0;
  static const int _sleepingThresholdFrames = 25; // 5s of no motion

  // ── Response latency tracking ──────────────────────────────────────────────
  int? _firstResponseLatencyMs;

  // ── Previous frame brightness for shake detection ──────────────────────────
  double _prevBrightness = 128.0;

  // ── Frame counter for debug logging ────────────────────────────────────────
  int _frameCount = 0;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Set infant age for age-adaptive scoring weights.
  void setInfantAge(int ageMonths) {
    _ageGroup = BoaInfantAgeGroup.fromMonths(ageMonths);
    debugPrint('[BoaCV] Age group set to: ${_ageGroup.label}');
  }

  /// Initialize pose detector. Call after camera is ready.
  /// Automatically disables on low-memory devices.
  Future<void> initializePoseDetector() async {
    try {
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          model: PoseDetectionModel.base,
        ),
      );
      _poseEnabled = true;
      debugPrint('[BoaCV] Pose detector initialized (dual-pipeline mode).');
    } catch (e) {
      debugPrint('[BoaCV] Pose detector init failed: $e — falling back to face-only mode.');
      _poseEnabled = false;
    }
  }

  /// Call this when a stimulus begins playing.
  void onStimulusStart() {
    _stimulusStartTime = DateTime.now();
    _isInResponseWindow = false;
    _firstResponseLatencyMs = null;

    // Snapshot pre-stimulus levels for change detection
    _preStimMotion = _motionBuffer.isNotEmpty
        ? _motionBuffer.reduce((a, b) => a + b) / _motionBuffer.length
        : 0.0;
    _preStimEyeOpenness = _eyeOpennessBuffer.isNotEmpty
        ? _eyeOpennessBuffer.reduce((a, b) => a + b) / _eyeOpennessBuffer.length
        : 0.5;
    _preStimArmExtension = _armExtensionBuffer.isNotEmpty
        ? _armExtensionBuffer.reduce((a, b) => a + b) / _armExtensionBuffer.length
        : 0.0;

    debugPrint('[BoaCV] ▶ Stimulus started. Pre-stim: motion=$_preStimMotion, eye=$_preStimEyeOpenness, arm=$_preStimArmExtension');
  }

  /// Call this when stimulus ends (response window opens).
  void onStimulusEnd() {
    _isInResponseWindow = true;
  }

  /// Call this when response is recorded or window closes.
  void onResponseWindowClose() {
    _stimulusStartTime = null;
    _isInResponseWindow = false;
    _firstResponseLatencyMs = null;
  }

  void reset() {
    _motionBuffer.clear();
    _eyeOpennessBuffer.clear();
    _eyeRocBuffer.clear();
    _bboxBuffer.clear();
    _headYBuffer.clear();
    _headXBuffer.clear();
    _armExtensionBuffer.clear();
    _bodyMotionBuffer.clear();
    _poseHistory.clear();
    _baseline.isCalibrated = false;
    _baseline.calibrationFrames = 0;
    _baseline.headY = 0.0;
    _baseline.headX = 0.0;
    _baseline.headYVariance = 0.0;
    _baseline.eyeOpenness = 0.5;
    _baseline.eyeOpennessVariance = 0.0;
    _baseline.overallMotion = 0.0;
    _baseline.armExtension = 0.0;
    _stimulusStartTime = null;
    _isInResponseWindow = false;
    _preStimMotion = 0.0;
    _preStimEyeOpenness = 0.5;
    _preStimArmExtension = 0.0;
    _lowMotionFrameCount = 0;
    _firstResponseLatencyMs = null;
    _frameCount = 0;
  }

  /// Main frame analysis method — runs both pipelines SEQUENTIALLY.
  Future<CvAnalysisResult> analyzeFrame(
    CameraImage image,
    InputImageRotation rotation, {
    bool isActiveTrial = false,
  }) async {
    _frameCount++;

    // ── 0. Lighting check ─────────────────────────────────────────────────
    _prevBrightness = _lastBrightness;
    _lastBrightness = _calculateBrightness(image);
    if (_lastBrightness < 25) {  // LOWERED from 35 — allow dimmer rooms
      return CvAnalysisResult(
        babyPresent: false,
        presenceConfidence: 0.1,
        detectionType: AiDetectionType.none,
        responseConfidence: 0,
        brightness: _lastBrightness,
      );
    }

    // ── 1. Prepare input image ────────────────────────────────────────────
    final inputImage = _prepareInputImage(image, rotation);
    if (inputImage == null) return CvAnalysisResult.empty();

    // ── 2. Run pipelines SEQUENTIALLY (prevents OOM on mid-range devices) ─
    late List<Face> faces;
    List<Pose> poses = [];

    try {
      // Pipeline A: Face detection (always runs)
      faces = await _faceDetector.processImage(inputImage);

      // Pipeline B: Pose detection (runs only if face found, to save CPU)
      if (_poseEnabled && _poseDetector != null && faces.isNotEmpty) {
        try {
          poses = await _poseDetector!.processImage(inputImage);
        } catch (e) {
          // Pose detection failed — continue with face-only
          debugPrint('[BoaCV] Pose detection error (non-fatal): $e');
          _poseEnabled = false; // Disable for remaining session
        }
      }
    } catch (e) {
      debugPrint('[BoaCV] Detection error: $e');
      return CvAnalysisResult.empty();
    }

    if (faces.isEmpty) {
      _bboxBuffer.clear();
      return CvAnalysisResult(
        babyPresent: false,
        presenceConfidence: 0,
        detectionType: AiDetectionType.noBabyDetected,
        responseConfidence: 0,
        brightness: _lastBrightness,
      );
    }

    // ── 3. Select infant face (multi-face handling) ───────────────────────
    final face = _selectInfantFace(faces, image.width, image.height);

    // ── 4. Presence validation (RELAXED thresholds) ───────────────────────
    final presenceConf = _calculatePresenceConfidence(face, image.width, image.height);
    if (presenceConf < 0.40) {  // LOWERED from 0.70
      return CvAnalysisResult(
        babyPresent: false,
        presenceConfidence: presenceConf,
        detectionType: AiDetectionType.positionBaby,
        responseConfidence: 0,
        brightness: _lastBrightness,
      );
    }

    // ── 5. Feature extraction (Pipeline A: Face) ──────────────────────────
    final leftEye = face.leftEyeOpenProbability ?? 0.5;
    final rightEye = face.rightEyeOpenProbability ?? 0.5;
    final eyeOpenness = (leftEye + rightEye) / 2.0;
    final motionMetric = _calculateMotionMetric(face);
    final headY = face.headEulerAngleY ?? 0.0;
    final headX = face.headEulerAngleX ?? 0.0;

    // Track eye rate-of-change (blink detection)
    if (_eyeOpennessBuffer.isNotEmpty) {
      final prevEye = _eyeOpennessBuffer.last;
      final eyeRoc = (eyeOpenness - prevEye).abs();
      _updateBuffer(_eyeRocBuffer, eyeRoc);
    }

    _updateBuffer(_eyeOpennessBuffer, eyeOpenness);
    _updateBuffer(_motionBuffer, motionMetric);
    _updateBuffer(_headYBuffer, headY);
    _updateBuffer(_headXBuffer, headX);
    _bboxBuffer.add(face.boundingBox);
    if (_bboxBuffer.length > _bufferSize) _bboxBuffer.removeAt(0);

    // ── 6. Feature extraction (Pipeline B: Pose) ──────────────────────────
    double armExtension = 0.0;
    double bodyMotion = 0.0;
    double poseConf = 0.0;

    if (poses.isNotEmpty) {
      final pose = poses.first;
      final landmarks = <PoseLandmarkType, PoseLandmark>{};
      for (final lm in pose.landmarks.entries) {
        landmarks[lm.key] = lm.value;
      }

      armExtension = _calculateArmExtension(landmarks);
      bodyMotion = _calculateBodyMotion(landmarks);
      poseConf = _calculatePoseConfidence(landmarks);

      _updateBuffer(_armExtensionBuffer, armExtension);
      _updateBuffer(_bodyMotionBuffer, bodyMotion);
      _poseHistory.add(landmarks);
      if (_poseHistory.length > _bufferSize) _poseHistory.removeAt(0);
    }

    // ── 7. Sleeping state detection ───────────────────────────────────────
    if (motionMetric < 2.0 && bodyMotion < 1.5) {
      _lowMotionFrameCount++;
    } else {
      _lowMotionFrameCount = 0;
    }

    // ── 8. Baseline calibration (FASTER + continuous update) ──────────────
    if (!_baseline.isCalibrated && _motionBuffer.length >= _baselineSize) {
      _calibrateBaseline();
    } else if (_baseline.isCalibrated && !isActiveTrial) {
      // Continuously update baseline when NOT in active trial
      _baseline.calibrationFrames++;
      if (_baseline.calibrationFrames % 10 == 0) {
        _updateRunningBaseline();
      }
    }

    AiDetectionType detectionType = AiDetectionType.babyDetected;
    double responseConfidence = 0.0;
    ResponseStrength strength = ResponseStrength.none;
    final List<AiDetectionType> detectedBehaviors = [];
    CvSignalScores signalScores = const CvSignalScores();

    // ── 9. Response analysis (ONLY during active trial) ────────────────────
    if (isActiveTrial && _baseline.isCalibrated) {
      final withinWindow = _checkResponseWindow();

      if (withinWindow || _isInResponseWindow) {
        // Check for camera shake — filter out before scoring
        if (_detectCameraShake()) {
          return CvAnalysisResult(
            babyPresent: true,
            presenceConfidence: presenceConf,
            detectionType: AiDetectionType.babyDetected,
            responseConfidence: 0,
            brightness: _lastBrightness,
            poseConfidence: poseConf,
          );
        }

        // ── Age-adaptive signal weights ─────────────────────────────────
        final weights = _getAgeAdaptiveWeights();

        // ── Signal scores (ALL LOWERED THRESHOLDS) ──────────────────────
        final headTurnScore = _scoreHeadTurn(headY);
        final eyeChangeScore = _scoreEyeChange(eyeOpenness);
        final bodyMoveScore = _scoreBodyMovement(bodyMotion);
        final moroScore = _scoreMoroReflex(armExtension);
        final freezeScore = _scoreFreezing(motionMetric, bodyMotion);
        final timingScore = _scoreTimingAccuracy();

        // ── Weighted fusion ─────────────────────────────────────────────
        responseConfidence = (weights['headTurn']! * headTurnScore) +
                             (weights['eyeChange']! * eyeChangeScore) +
                             (weights['bodyMovement']! * bodyMoveScore) +
                             (weights['moroReflex']! * moroScore) +
                             (weights['freezing']! * freezeScore) +
                             (weights['timing']! * timingScore);

        responseConfidence = responseConfidence.clamp(0.0, 1.0);

        signalScores = CvSignalScores(
          headTurn: headTurnScore,
          eyeChange: eyeChangeScore,
          bodyMovement: bodyMoveScore,
          moroReflex: moroScore,
          freezing: freezeScore,
          timing: timingScore,
        );

        // ── Detect which behaviors triggered (LOWERED from 0.3 to 0.15) ─
        if (headTurnScore > 0.15) detectedBehaviors.add(AiDetectionType.headTurn);
        if (eyeChangeScore > 0.15) detectedBehaviors.add(AiDetectionType.eyeBlink);
        if (bodyMoveScore > 0.15) detectedBehaviors.add(AiDetectionType.bodyMovement);
        if (moroScore > 0.15) detectedBehaviors.add(AiDetectionType.armExtension);
        if (freezeScore > 0.15) detectedBehaviors.add(AiDetectionType.freezing);

        // ── Determine dominant detection type (LOWERED thresholds) ──────
        if (moroScore > 0.35 && moroScore >= headTurnScore) {
          detectionType = AiDetectionType.moroReflex;
        } else if (headTurnScore > 0.25) {
          detectionType = AiDetectionType.headTurn;
        } else if (freezeScore > 0.30) {
          detectionType = AiDetectionType.freezing;
        } else if (eyeChangeScore > 0.25) {
          detectionType = AiDetectionType.eyeBlink;
        } else if (bodyMoveScore > 0.20) {
          detectionType = AiDetectionType.bodyMovement;
        } else if (responseConfidence > 0.12) {
          detectionType = AiDetectionType.alerting;
        }

        // ── Track first response latency ────────────────────────────────
        if (responseConfidence > 0.15 && _firstResponseLatencyMs == null && _stimulusStartTime != null) {
          _firstResponseLatencyMs = DateTime.now().difference(_stimulusStartTime!).inMilliseconds;
          debugPrint('[BoaCV] ★ First response detected at ${_firstResponseLatencyMs}ms');
        }

        strength = _classifyStrength(responseConfidence);

        // Log every 3rd frame during active trial for debugging
        if (_frameCount % 3 == 0) {
          debugPrint(
            '[BoaCV] [$_ageGroup] head:${headTurnScore.toStringAsFixed(2)} '
            'eye:${eyeChangeScore.toStringAsFixed(2)} '
            'body:${bodyMoveScore.toStringAsFixed(2)} '
            'moro:${moroScore.toStringAsFixed(2)} '
            'freeze:${freezeScore.toStringAsFixed(2)} '
            'timing:${timingScore.toStringAsFixed(2)} '
            '→ ${responseConfidence.toStringAsFixed(2)} ($strength)');
        }
      }
    }

    // ── 10. Build explanation ─────────────────────────────────────────────
    final warnings = <String>[];
    if (_lowMotionFrameCount >= _sleepingThresholdFrames) {
      warnings.add('Infant may be sleeping — ensure alert state');
    }
    if (_lastBrightness < 50) {
      warnings.add('Low light conditions');
    }

    String qualityNote = '';
    if (presenceConf > 0.85 && _baseline.isCalibrated) {
      qualityNote = 'Good visibility, stable baseline';
    } else if (presenceConf > 0.55) {
      qualityNote = 'Adequate visibility';
    } else {
      qualityNote = 'Marginal visibility — move closer';
    }

    final explanation = CvExplanation(
      primaryBehavior: _behaviorLabel(detectionType),
      latencyMs: _firstResponseLatencyMs ?? 0,
      confidence: responseConfidence,
      qualityNote: qualityNote,
      detectedBehaviors: List.unmodifiable(detectedBehaviors),
      warnings: warnings,
      signalScores: signalScores,
    );

    return CvAnalysisResult(
      babyPresent: true,
      presenceConfidence: presenceConf,
      detectionType: detectionType,
      responseConfidence: responseConfidence,
      responseStrength: strength,
      motionMetric: motionMetric,
      isWithinResponseWindow: _isInResponseWindow,
      brightness: _lastBrightness,
      poseConfidence: poseConf,
      detectedBehaviors: List.unmodifiable(detectedBehaviors),
      explanation: explanation,
      signalScores: signalScores,
      responseLatencyMs: _firstResponseLatencyMs,
    );
  }

  // ── Baseline Calibration ──────────────────────────────────────────────────

  void _calibrateBaseline() {
    _baseline.overallMotion = _motionBuffer.reduce((a, b) => a + b) / _motionBuffer.length;
    _baseline.eyeOpenness = _eyeOpennessBuffer.reduce((a, b) => a + b) / _eyeOpennessBuffer.length;
    _baseline.headY = _headYBuffer.reduce((a, b) => a + b) / _headYBuffer.length;
    if (_headXBuffer.isNotEmpty) {
      _baseline.headX = _headXBuffer.reduce((a, b) => a + b) / _headXBuffer.length;
    }

    // Calculate variances for adaptive thresholds
    final meanY = _baseline.headY;
    _baseline.headYVariance = _headYBuffer
        .map((v) => (v - meanY) * (v - meanY))
        .reduce((a, b) => a + b) / _headYBuffer.length;

    final meanEye = _baseline.eyeOpenness;
    _baseline.eyeOpennessVariance = _eyeOpennessBuffer
        .map((v) => (v - meanEye) * (v - meanEye))
        .reduce((a, b) => a + b) / _eyeOpennessBuffer.length;

    if (_armExtensionBuffer.length >= _baselineSize) {
      _baseline.armExtension = _armExtensionBuffer.reduce((a, b) => a + b) / _armExtensionBuffer.length;
    }

    _baseline.isCalibrated = true;
    debugPrint('[BoaCV] ✓ Baseline calibrated in $_frameCount frames. '
        'Motion=${_baseline.overallMotion.toStringAsFixed(1)}, '
        'Eye=${_baseline.eyeOpenness.toStringAsFixed(2)}±${sqrt(_baseline.eyeOpennessVariance).toStringAsFixed(3)}, '
        'HeadY=${_baseline.headY.toStringAsFixed(1)}±${sqrt(_baseline.headYVariance).toStringAsFixed(1)}, '
        'Arm=${_baseline.armExtension.toStringAsFixed(1)}');
  }

  /// Update baseline with exponential moving average (keeps it fresh)
  void _updateRunningBaseline() {
    if (_motionBuffer.isEmpty || _eyeOpennessBuffer.isEmpty) return;
    const alpha = 0.15; // Slow adaptation
    final currentMotion = _motionBuffer.last;
    final currentEye = _eyeOpennessBuffer.last;
    final currentHeadY = _headYBuffer.isNotEmpty ? _headYBuffer.last : _baseline.headY;

    _baseline.overallMotion = _baseline.overallMotion * (1 - alpha) + currentMotion * alpha;
    _baseline.eyeOpenness = _baseline.eyeOpenness * (1 - alpha) + currentEye * alpha;
    _baseline.headY = _baseline.headY * (1 - alpha) + currentHeadY * alpha;
  }

  // ── Age-Adaptive Weights ──────────────────────────────────────────────────

  Map<String, double> _getAgeAdaptiveWeights() {
    switch (_ageGroup) {
      case BoaInfantAgeGroup.neonatal: // 0–3 months
        return {
          'headTurn': 0.08,    // Neck too weak for reliable turns
          'eyeChange': 0.28,   // Eye widening/blink is most reliable at this age
          'bodyMovement': 0.18,
          'moroReflex': 0.25,  // Moro reflex strongest at this age
          'freezing': 0.10,
          'timing': 0.11,
        };
      case BoaInfantAgeGroup.earlyInfant: // 3–6 months
        return {
          'headTurn': 0.22,    // Head control emerging
          'eyeChange': 0.25,   // Still important
          'bodyMovement': 0.18,
          'moroReflex': 0.10,  // Moro reflex diminishing
          'freezing': 0.13,
          'timing': 0.12,
        };
      case BoaInfantAgeGroup.olderInfant: // 6–12 months
        return {
          'headTurn': 0.32,    // Head turn is primary indicator
          'eyeChange': 0.18,
          'bodyMovement': 0.15,
          'moroReflex': 0.05,  // Moro largely absent
          'freezing': 0.15,
          'timing': 0.15,
        };
    }
  }

  // ── Pipeline A Scoring Methods (Face-Based) ───────────────────────────────

  /// Head turn score: uses adaptive thresholds based on baseline variance.
  double _scoreHeadTurn(double currentHeadY) {
    if (_headYBuffer.length < 3) return 0.0;

    // Use recent 3-frame average to smooth noise
    final recentAvg = _headYBuffer.sublist(max(0, _headYBuffer.length - 3))
        .reduce((a, b) => a + b) / 3;
    final delta = (recentAvg - _baseline.headY).abs();

    // Adaptive threshold: minimum 5° (was 10°), scaled by natural variance
    final naturalVariance = sqrt(_baseline.headYVariance);
    final threshold = max(5.0, naturalVariance * 2.0);  // LOWERED from max(10, var*2.5)

    if (delta < threshold * 0.6) return 0.0;
    if (delta < threshold) return 0.25;
    if (delta < threshold * 1.5) return 0.55;
    if (delta < threshold * 2.0) return 0.80;
    return 1.0;
  }

  /// Eye change score: uses rate-of-change for blink detection + delta for sustained changes.
  double _scoreEyeChange(double currentEyeOpenness) {
    if (_eyeOpennessBuffer.length < 3) return 0.0;

    // Method 1: Absolute delta from baseline
    final delta = (currentEyeOpenness - _baseline.eyeOpenness).abs();

    // Method 2: Rate of change (catches fast blinks)
    double rocScore = 0.0;
    if (_eyeRocBuffer.length >= 2) {
      final recentRoc = _eyeRocBuffer.sublist(max(0, _eyeRocBuffer.length - 3))
          .reduce((a, b) => a + b) / min(3, _eyeRocBuffer.length);
      // A blink typically produces ROC > 0.1 in a single frame at 5fps
      if (recentRoc > 0.06) rocScore = 0.3;       // LOWERED
      if (recentRoc > 0.12) rocScore = 0.6;
      if (recentRoc > 0.20) rocScore = 0.9;
    }

    // Method 3: Sudden eye closure (blink = eyes went from open to closed)
    double blinkScore = 0.0;
    if (_eyeOpennessBuffer.length >= 3) {
      final prev = _eyeOpennessBuffer[_eyeOpennessBuffer.length - 3];
      final curr = currentEyeOpenness;
      // Blink: was open (>0.4), now closed (<0.2)
      if (prev > 0.35 && curr < 0.20) {
        blinkScore = 0.85;
      }
      // Eye widening: was normal, now wide
      else if (prev < 0.6 && curr > 0.75) {
        blinkScore = 0.5;
      }
    }

    // Delta-based score (LOWERED thresholds)
    double deltaScore = 0.0;
    final eyeVariance = sqrt(_baseline.eyeOpennessVariance);
    final adaptiveThreshold = max(0.08, eyeVariance * 2.0);  // LOWERED from 0.15

    if (delta > adaptiveThreshold * 0.5) deltaScore = 0.15;
    if (delta > adaptiveThreshold) deltaScore = 0.40;
    if (delta > adaptiveThreshold * 2.0) deltaScore = 0.70;
    if (delta > adaptiveThreshold * 3.0) deltaScore = 0.95;

    // Take the best of all methods
    return max(deltaScore, max(rocScore, blinkScore)).clamp(0.0, 1.0);
  }

  // ── Pipeline B Scoring Methods (Pose-Based) ───────────────────────────────

  /// Body movement score: limb velocity from pose keypoints.
  double _scoreBodyMovement(double currentBodyMotion) {
    if (!_baseline.isCalibrated || _bodyMotionBuffer.length < 2) return 0.0;

    // LOWERED thresholds
    final threshold = max(_preStimMotion * 1.5, _baseline.overallMotion * 1.8).clamp(2.0, 50.0);
    if (currentBodyMotion < threshold) return 0.0;

    final rawScore = ((currentBodyMotion / threshold) - 1.0) * 0.7;  // More sensitive
    return rawScore.clamp(0.0, 1.0);
  }

  /// Moro reflex score: detects arm extension pattern.
  double _scoreMoroReflex(double currentArmExtension) {
    if (!_baseline.isCalibrated || _armExtensionBuffer.length < 2) return 0.0;

    final delta = currentArmExtension - _preStimArmExtension;
    if (delta < 0) return 0.0; // Arms contracting, not extending

    // LOWERED thresholds
    final threshold = max(_baseline.armExtension * 1.15, 10.0);
    if (currentArmExtension < threshold) return 0.0;

    final bboxShift = _calculateBboxShift();
    final rawScore = min(1.0, (delta / max(threshold, 1.0)) * 0.7 + (bboxShift ? 0.25 : 0.0));
    return rawScore.clamp(0.0, 1.0);
  }

  /// Freezing score: detects motion CESSATION as a response.
  double _scoreFreezing(double currentMotion, double currentBodyMotion) {
    if (!_baseline.isCalibrated) return 0.0;

    final preStimLevel = _preStimMotion;
    if (preStimLevel < 3.0) return 0.0;  // LOWERED from 5.0

    final totalMotion = currentMotion + currentBodyMotion;
    final motionDrop = preStimLevel - totalMotion;

    if (motionDrop < preStimLevel * 0.35) return 0.0;  // LOWERED from 0.5
    if (motionDrop < preStimLevel * 0.55) return 0.4;
    return 0.8;
  }

  // ── Shared Scoring Methods ────────────────────────────────────────────────

  /// Timing score: wider window (150ms–3500ms), peaks at 250–1200ms.
  double _scoreTimingAccuracy() {
    if (_stimulusStartTime == null) return 0.0;
    final ms = DateTime.now().difference(_stimulusStartTime!).inMilliseconds;
    if (ms < 150) return 0.0;    // Too early (reflex latency floor)
    if (ms < 250) return 0.3;    // Very early — possible but uncertain
    if (ms < 600) return 1.0;    // Peak response window
    if (ms < 1200) return 0.9;   // Very strong
    if (ms < 2000) return 0.6;   // Good
    if (ms < 3000) return 0.4;   // Late but plausible
    if (ms < 3500) return 0.2;   // Marginal
    return 0.0;                  // Outside clinical window
  }

  bool _checkResponseWindow() {
    if (_stimulusStartTime == null) return false;
    final ms = DateTime.now().difference(_stimulusStartTime!).inMilliseconds;
    return ms >= 150 && ms <= 3500;  // WIDENED from 200-3000
  }

  ResponseStrength _classifyStrength(double confidence) {
    if (confidence < 0.15) return ResponseStrength.none;     // LOWERED from 0.25
    if (confidence < 0.35) return ResponseStrength.weak;     // LOWERED from 0.50
    if (confidence < 0.60) return ResponseStrength.probable; // LOWERED from 0.75
    return ResponseStrength.strong;
  }

  // ── Pose Feature Calculations ─────────────────────────────────────────────

  double _calculateArmExtension(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    double extension = 0.0;
    int count = 0;

    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];

    // LOWERED confidence threshold from 0.5 to 0.3
    if (leftShoulder != null && leftWrist != null &&
        leftShoulder.likelihood > 0.3 && leftWrist.likelihood > 0.3) {
      extension += _distance(leftShoulder, leftWrist);
      count++;
    }
    if (rightShoulder != null && rightWrist != null &&
        rightShoulder.likelihood > 0.3 && rightWrist.likelihood > 0.3) {
      extension += _distance(rightShoulder, rightWrist);
      count++;
    }

    return count > 0 ? extension / count : 0.0;
  }

  double _calculateBodyMotion(Map<PoseLandmarkType, PoseLandmark> currentLandmarks) {
    if (_poseHistory.isEmpty) return 0.0;

    final prev = _poseHistory.last;
    double totalDisplacement = 0.0;
    int count = 0;

    const trackedPoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
    ];

    for (final pt in trackedPoints) {
      final curr = currentLandmarks[pt];
      final previous = prev[pt];
      // LOWERED confidence from 0.4 to 0.25
      if (curr != null && previous != null &&
          curr.likelihood > 0.25 && previous.likelihood > 0.25) {
        final dx = curr.x - previous.x;
        final dy = curr.y - previous.y;
        totalDisplacement += sqrt(dx * dx + dy * dy);
        count++;
      }
    }

    return count > 0 ? totalDisplacement / count : 0.0;
  }

  double _calculatePoseConfidence(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    const keyPoints = [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.rightElbow,
    ];

    double totalConf = 0.0;
    int count = 0;
    for (final pt in keyPoints) {
      final lm = landmarks[pt];
      if (lm != null) {
        totalConf += lm.likelihood;
        count++;
      }
    }
    return count > 0 ? totalConf / count : 0.0;
  }

  double _distance(PoseLandmark a, PoseLandmark b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  // ── Multi-Face Infant Selection ───────────────────────────────────────────

  Face _selectInfantFace(List<Face> faces, int imgW, int imgH) {
    if (faces.length == 1) return faces.first;

    final screenArea = imgW * imgH;
    final imgCenterX = imgW / 2.0;

    Face best = faces.first;
    double bestScore = -1;

    for (final face in faces) {
      final area = face.boundingBox.width * face.boundingBox.height;
      final ratio = area / screenArea;

      if (ratio < 0.02) continue;  // LOWERED from 0.03

      // Smaller faces score higher (infant vs adult)
      double sizeScore = ratio < 0.12 ? 1.0 : (ratio < 0.25 ? 0.5 : 0.2);

      // Centered faces score higher
      final centerDist = (face.boundingBox.center.dx - imgCenterX).abs() / imgW;
      double centerScore = centerDist < 0.20 ? 1.0 : (centerDist < 0.35 ? 0.5 : 0.2);

      // Bonus for eye detection
      double eyeBonus = (face.leftEyeOpenProbability != null) ? 0.3 : 0.0;

      final score = sizeScore + centerScore + eyeBonus;
      if (score > bestScore) {
        bestScore = score;
        best = face;
      }
    }

    return best;
  }

  // ── Camera Shake Detection (RELAXED) ──────────────────────────────────────

  bool _detectCameraShake() {
    if (_bboxBuffer.length < 3) return false;

    final last = _bboxBuffer.last;
    final prev = _bboxBuffer[_bboxBuffer.length - 3];

    final dx = (last.center.dx - prev.center.dx).abs();
    final dy = (last.center.dy - prev.center.dy).abs();
    final displacement = dx + dy;
    final faceSize = max(last.width + last.height, 1.0);
    final normalizedDisp = displacement / faceSize;

    final brightnessDelta = (_lastBrightness - _prevBrightness).abs();

    // RAISED threshold from 0.15 to 0.25 — less aggressive shake rejection
    if (normalizedDisp > 0.25) {
      if (_headYBuffer.length >= 3) {
        final headDelta = (_headYBuffer.last - _headYBuffer[_headYBuffer.length - 3]).abs();
        if (headDelta < 4.0) {  // LOWERED from 5.0
          return true;
        }
      }
    }

    // RAISED brightness threshold from 30 to 40
    if (brightnessDelta > 40) return true;

    return false;
  }

  // ── Helper Methods ────────────────────────────────────────────────────────

  bool _calculateBboxShift() {
    if (_bboxBuffer.length < 3) return false;
    final last = _bboxBuffer.last;
    final prev = _bboxBuffer[_bboxBuffer.length - 3];
    final dx = (last.center.dx - prev.center.dx).abs();
    final dy = (last.center.dy - prev.center.dy).abs();
    final normalized = (dx + dy) / max(last.width + last.height, 1);
    return normalized > 0.10;  // LOWERED from 0.12
  }

  double _calculatePresenceConfidence(Face face, int imgW, int imgH) {
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    final screenArea = imgW * imgH;
    final ratio = faceArea / screenArea;

    // SIGNIFICANTLY RELAXED — infant at arm's length is ~3-5% of frame
    if (ratio < 0.02) return 0.15;   // Very tiny (was 0.06 → 0.2)
    if (ratio < 0.04) return 0.45;   // Small but usable
    if (ratio < 0.06) return 0.60;   // Decent

    final centerX = face.boundingBox.center.dx;
    final imgCenterX = imgW / 2.0;
    final distFromCenter = (centerX - imgCenterX).abs() / imgW;
    if (distFromCenter > 0.40) return 0.40;  // RELAXED from 0.35

    if (face.leftEyeOpenProbability == null &&
        face.rightEyeOpenProbability == null) {
      return 0.50;  // No eye data but face detected
    }

    if (ratio > 0.06 && distFromCenter < 0.25) return 0.95;
    return 0.75;  // RAISED from 0.82 to be safer
  }

  double _calculateMotionMetric(Face face) {
    return (face.headEulerAngleX?.abs() ?? 0) +
           (face.headEulerAngleY?.abs() ?? 0) +
           (face.headEulerAngleZ?.abs() ?? 0);
  }

  double _calculateBrightness(CameraImage image) {
    final bytes = image.planes[0].bytes;
    if (bytes.isEmpty) return 128.0;
    double sum = 0;
    const step = 120;
    int count = 0;
    for (int i = 0; i < bytes.length; i += step) {
      sum += bytes[i];
      count++;
    }
    return count > 0 ? sum / count : 128.0;
  }

  void _updateBuffer(List<double> buffer, double value) {
    buffer.add(value);
    if (buffer.length > _bufferSize) buffer.removeAt(0);
  }

  InputImage? _prepareInputImage(CameraImage image, InputImageRotation rotation) {
    try {
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      if (image.planes.isEmpty) return null;
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('[BoaCV] prepareInputImage error: $e');
      return null;
    }
  }

  String _behaviorLabel(AiDetectionType type) {
    switch (type) {
      case AiDetectionType.headTurn: return 'Head turn';
      case AiDetectionType.eyeBlink: return 'Eye response';
      case AiDetectionType.moroReflex: return 'Startle reflex';
      case AiDetectionType.bodyMovement: return 'Body movement';
      case AiDetectionType.freezing: return 'Freezing (motion cessation)';
      case AiDetectionType.alerting: return 'Alerting response';
      case AiDetectionType.armExtension: return 'Arm extension';
      default: return 'None';
    }
  }

  Future<void> dispose() async {
    await _faceDetector.close();
    await _poseDetector?.close();
  }
}
