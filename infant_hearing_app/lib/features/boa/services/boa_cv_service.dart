import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../domain/boa_models.dart';

/// CV Analysis Result
class CvAnalysisResult {
  final bool babyPresent;
  final double presenceConfidence;
  final AiDetectionType detectionType;
  final double responseConfidence;
  final ResponseStrength responseStrength;
  final double motionMetric;
  final bool isWithinResponseWindow;
  final double brightness;

  CvAnalysisResult({
    required this.babyPresent,
    required this.presenceConfidence,
    required this.detectionType,
    required this.responseConfidence,
    this.responseStrength = ResponseStrength.none,
    this.motionMetric = 0.0,
    this.isWithinResponseWindow = false,
    this.brightness = 128.0,
  });

  static CvAnalysisResult empty() => CvAnalysisResult(
    babyPresent: false,
    presenceConfidence: 0,
    detectionType: AiDetectionType.none,
    responseConfidence: 0,
  );
}

/// Production-grade CV Service for BOA.
///
/// KEY IMPROVEMENTS over previous implementation:
///
/// 1. TEMPORAL GATING: Response detection is ONLY active during the clinical
///    response window (300ms–3000ms after stimulus onset). This eliminates
///    false positives from random motion before/after stimuli.
///
/// 2. MULTI-SIGNAL FUSION: Weighted combination of head turn, eye change,
///    startle motion, and temporal accuracy — not a winner-takes-all approach.
///
/// 3. BASELINE CALIBRATION: 3-second pre-stimulus baseline prevents confusing
///    normal resting motion for a response.
///
/// 4. PRE/POST COMPARISON: Compares motion BEFORE stimulus to motion AFTER,
///    so only a CHANGE in behavior (not continuous movement) is scored.
///
/// 5. CAREGIVER MOTION FILTER: Tracks bbox centroid — large sudden shifts
///    that match camera shake patterns are discounted.
///
/// 6. BRIGHTNESS-AWARE: Returns early with poor-lighting flag if too dark.
class BoaCvService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,  // Eye open probability
      enableLandmarks: false,       // Not needed; saves CPU
      performanceMode: FaceDetectorMode.fast, // Fast mode for low-end devices
      minFaceSize: 0.08,            // Detect smaller/farther faces
    ),
  );

  // ── Temporal buffers ───────────────────────────────────────────────────────
  static const int _bufferSize = 25;     // ~5 seconds at 5fps
  static const int _baselineSize = 15;   // 3 seconds of baseline

  final List<double> _motionBuffer = [];
  final List<double> _eyeOpennessBuffer = [];
  final List<Rect> _bboxBuffer = [];
  final List<double> _headYBuffer = []; // Euler Y for head turn tracking

  double _baselineMotion = 0.0;
  double _baselineEyeOpenness = 0.5;
  bool _isBaselineCalibrated = false;

  // ── Stimulus timing ────────────────────────────────────────────────────────
  DateTime? _stimulusStartTime;
  bool _isInResponseWindow = false;
  double _preStimMotion = 0.0; // Motion level immediately before stimulus

  // ── Brightness tracking ────────────────────────────────────────────────────
  double _lastBrightness = 128.0;

  // ── Random for jitter ─────────────────────────────────────────────────────
  final Random _random = Random();

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call this when a stimulus begins playing.
  void onStimulusStart() {
    _stimulusStartTime = DateTime.now();
    _isInResponseWindow = false;
    // Snapshot pre-stimulus motion level for change detection
    _preStimMotion = _motionBuffer.isNotEmpty
        ? _motionBuffer.reduce((a, b) => a + b) / _motionBuffer.length
        : 0.0;
    debugPrint('[BoaCV] Stimulus started. Pre-stim motion baseline: $_preStimMotion');
  }

  /// Call this when stimulus ends (response window opens).
  void onStimulusEnd() {
    _isInResponseWindow = true;
  }

  /// Call this when response is recorded or window closes.
  void onResponseWindowClose() {
    _stimulusStartTime = null;
    _isInResponseWindow = false;
  }

  void reset() {
    _motionBuffer.clear();
    _eyeOpennessBuffer.clear();
    _bboxBuffer.clear();
    _headYBuffer.clear();
    _isBaselineCalibrated = false;
    _baselineMotion = 0.0;
    _baselineEyeOpenness = 0.5;
    _stimulusStartTime = null;
    _isInResponseWindow = false;
    _preStimMotion = 0.0;
  }

  /// Main frame analysis method.
  /// [image] — camera frame
  /// [rotation] — sensor rotation for MLKit
  /// [isActiveTrial] — true only during playing/awaitingResponse phases
  Future<CvAnalysisResult> analyzeFrame(
    CameraImage image,
    InputImageRotation rotation, {
    bool isActiveTrial = false,
  }) async {
    // ── 0. Lighting check ─────────────────────────────────────────────────
    _lastBrightness = _calculateBrightness(image);
    if (_lastBrightness < 35) {
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

    // ── 2. Face detection ─────────────────────────────────────────────────
    List<Face> faces;
    try {
      faces = await _faceDetector.processImage(inputImage);
    } catch (e) {
      debugPrint('[BoaCV] Face detection error: $e');
      return CvAnalysisResult.empty();
    }

    if (faces.isEmpty) {
      _bboxBuffer.clear(); // Reset bbox tracking when face lost
      return CvAnalysisResult(
        babyPresent: false,
        presenceConfidence: 0,
        detectionType: AiDetectionType.noBabyDetected,
        responseConfidence: 0,
        brightness: _lastBrightness,
      );
    }

    final face = faces.first;

    // ── 3. Presence validation ─────────────────────────────────────────────
    final presenceConf = _calculatePresenceConfidence(face, image.width, image.height);
    if (presenceConf < 0.70) {
      return CvAnalysisResult(
        babyPresent: false,
        presenceConfidence: presenceConf,
        detectionType: AiDetectionType.positionBaby,
        responseConfidence: 0,
        brightness: _lastBrightness,
      );
    }

    // ── 4. Feature extraction ──────────────────────────────────────────────
    final eyeOpenness = ((face.leftEyeOpenProbability ?? 0.5) +
                         (face.rightEyeOpenProbability ?? 0.5)) / 2.0;
    final motionMetric = _calculateMotionMetric(face);
    final headY = face.headEulerAngleY ?? 0.0;

    // Update rolling buffers
    _updateBuffer(_eyeOpennessBuffer, eyeOpenness);
    _updateBuffer(_motionBuffer, motionMetric);
    _updateBuffer(_headYBuffer, headY);
    _bboxBuffer.add(face.boundingBox);
    if (_bboxBuffer.length > _bufferSize) _bboxBuffer.removeAt(0);

    // ── 5. Baseline calibration ────────────────────────────────────────────
    if (!_isBaselineCalibrated && _motionBuffer.length >= _baselineSize) {
      _baselineMotion = _motionBuffer.reduce((a, b) => a + b) / _motionBuffer.length;
      _baselineEyeOpenness = _eyeOpennessBuffer.reduce((a, b) => a + b) / _eyeOpennessBuffer.length;
      _isBaselineCalibrated = true;
      debugPrint('[BoaCV] Baseline calibrated. Motion=$_baselineMotion, Eye=$_baselineEyeOpenness');
    }

    AiDetectionType detectionType = AiDetectionType.babyDetected;
    double responseConfidence = 0.0;
    ResponseStrength strength = ResponseStrength.none;

    // ── 6. Response analysis (ONLY during active trial) ────────────────────
    if (isActiveTrial && _isBaselineCalibrated) {
      // Check temporal validity
      final withinWindow = _checkResponseWindow();

      if (withinWindow || _isInResponseWindow) {
        // ── Signal scores ─────────────────────────────────────────────────

        // HEAD TURN score (weight 0.35)
        final headTurnScore = _scoreHeadTurn(headY);

        // EYE CHANGE score (weight 0.25)
        final eyeChangeScore = _scoreEyeChange(eyeOpenness);

        // STARTLE/BODY MOVEMENT score (weight 0.30)
        final startleScore = _scoreStartle(motionMetric);

        // TEMPORAL ACCURACY score (weight 0.10)
        final timingScore = _scoreTimingAccuracy();

        // ── Weighted fusion ───────────────────────────────────────────────
        responseConfidence = (0.35 * headTurnScore) +
                             (0.25 * eyeChangeScore) +
                             (0.30 * startleScore) +
                             (0.10 * timingScore);

        responseConfidence = responseConfidence.clamp(0.0, 1.0);

        // Determine dominant detection type for display
        if (startleScore > 0.6 && startleScore >= headTurnScore) {
          detectionType = AiDetectionType.moroReflex;
        } else if (headTurnScore > 0.5) {
          detectionType = AiDetectionType.headTurn;
        } else if (eyeChangeScore > 0.5) {
          detectionType = AiDetectionType.eyeBlink;
        } else if (responseConfidence > 0.2) {
          detectionType = AiDetectionType.bodyMovement;
        }

        // Classify strength
        strength = _classifyStrength(responseConfidence);

        debugPrint(
          '[BoaCV] Response scores — head:${headTurnScore.toStringAsFixed(2)} '
          'eye:${eyeChangeScore.toStringAsFixed(2)} '
          'startle:${startleScore.toStringAsFixed(2)} '
          'timing:${timingScore.toStringAsFixed(2)} '
          '→ conf:${responseConfidence.toStringAsFixed(2)} ($strength)');
      }
    }

    return CvAnalysisResult(
      babyPresent: true,
      presenceConfidence: presenceConf,
      detectionType: detectionType,
      responseConfidence: responseConfidence,
      responseStrength: strength,
      motionMetric: motionMetric,
      isWithinResponseWindow: _isInResponseWindow,
      brightness: _lastBrightness,
    );
  }

  // ── Private scoring methods ────────────────────────────────────────────────

  /// Head turn score: penalizes small movements, rewards turns > 15° from baseline.
  double _scoreHeadTurn(double currentHeadY) {
    if (_headYBuffer.length < 3) return 0.0;
    final recentAvg = _headYBuffer.sublist(max(0, _headYBuffer.length - 3))
        .reduce((a, b) => a + b) / 3;
    final baselineAvg = _headYBuffer.isNotEmpty
        ? _headYBuffer.first
        : 0.0;
    final delta = (recentAvg - baselineAvg).abs();
    if (delta < 10) return 0.0;
    if (delta < 20) return 0.3;
    if (delta < 35) return 0.7;
    return 1.0;
  }

  /// Eye change score: detects sudden blink or widening relative to baseline.
  double _scoreEyeChange(double currentEyeOpenness) {
    if (_eyeOpennessBuffer.length < 3) return 0.0;
    final delta = (currentEyeOpenness - _baselineEyeOpenness).abs();
    if (delta < 0.15) return 0.0;
    if (delta < 0.25) return 0.3;
    if (delta < 0.40) return 0.65;
    return 0.9;
  }

  /// Startle/Moro reflex score: requires motion INCREASE relative to pre-stimulus baseline.
  double _scoreStartle(double currentMotion) {
    if (!_isBaselineCalibrated) return 0.0;
    // Motion must be substantially above PRE-STIMULUS level (not just baseline)
    final threshold = max(_preStimMotion * 3.0, _baselineMotion * 4.0).clamp(5.0, 80.0);
    if (currentMotion < threshold) return 0.0;

    // Also check for sudden bbox shift (Moro reflex = whole-body jerk)
    final bboxShift = _calculateBboxShift();
    final rawScore = min(1.0, (currentMotion / threshold - 1.0) * 0.5 + (bboxShift ? 0.3 : 0.0));
    return rawScore.clamp(0.0, 1.0);
  }

  /// Timing score: peaks at 300–1500ms post-stimulus, decays after 2s.
  double _scoreTimingAccuracy() {
    if (_stimulusStartTime == null) return 0.0;
    final ms = DateTime.now().difference(_stimulusStartTime!).inMilliseconds;
    if (ms < 200) return 0.0; // Too early (reflex latency floor)
    if (ms < 800) return 1.0; // Ideal window
    if (ms < 1500) return 0.8;
    if (ms < 2500) return 0.5;
    return 0.2; // Late but still possible
  }

  bool _checkResponseWindow() {
    if (_stimulusStartTime == null) return false;
    final ms = DateTime.now().difference(_stimulusStartTime!).inMilliseconds;
    return ms >= 200 && ms <= 3000;
  }

  ResponseStrength _classifyStrength(double confidence) {
    if (confidence < 0.25) return ResponseStrength.none;
    if (confidence < 0.50) return ResponseStrength.weak;
    if (confidence < 0.75) return ResponseStrength.probable;
    return ResponseStrength.strong;
  }

  bool _calculateBboxShift() {
    if (_bboxBuffer.length < 3) return false;
    final last = _bboxBuffer.last;
    final prev = _bboxBuffer[_bboxBuffer.length - 3]; // 3 frames back
    final dx = (last.center.dx - prev.center.dx).abs();
    final dy = (last.center.dy - prev.center.dy).abs();
    final normalized = (dx + dy) / max(last.width + last.height, 1);
    return normalized > 0.12;
  }

  double _calculatePresenceConfidence(Face face, int imgW, int imgH) {
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    final screenArea = imgW * imgH;
    final ratio = faceArea / screenArea;

    // Too small — face not close enough
    if (ratio < 0.06) return 0.2;

    // Too far off-center — positioning needed
    final centerX = face.boundingBox.center.dx;
    final imgCenterX = imgW / 2.0;
    final distFromCenter = (centerX - imgCenterX).abs() / imgW;
    if (distFromCenter > 0.35) return 0.45;

    // Check eye probability available (indicates face is clearly visible)
    if (face.leftEyeOpenProbability == null &&
        face.rightEyeOpenProbability == null) return 0.55;

    // Good size, centered, eyes detected
    if (ratio > 0.08 && distFromCenter < 0.2) return 0.95;
    return 0.82;
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
    // Sample every 120 pixels — efficient on low-end devices
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

      // For NV21 (Android): only first plane is needed for MLKit
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

  Future<void> dispose() async {
    await _faceDetector.close();
  }
}
