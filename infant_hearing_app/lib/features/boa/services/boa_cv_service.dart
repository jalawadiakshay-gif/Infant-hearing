import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../domain/boa_models.dart';

/// CV Result data structure
class CvAnalysisResult {
  final bool babyPresent;
  final double presenceConfidence;
  final AiDetectionType detectionType;
  final double responseConfidence;
  final double motionMetric;

  CvAnalysisResult({
    required this.babyPresent,
    required this.presenceConfidence,
    required this.detectionType,
    required this.responseConfidence,
    this.motionMetric = 0.0,
  });
}

/// Advanced CV Service for BOA.
/// Implements 2-stage pipeline: Presence -> Response.
class BoaCvService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  // Temporal analysis buffers
  final List<double> _motionBuffer = [];
  final List<double> _eyeOpennessBuffer = [];
  final List<Rect> _bboxBuffer = []; // Track bounding box movement
  static const int _bufferSize = 20; // Increased for better smoothing

  double _baselineMotion = 0.0;
  bool _isCalibrated = false;

  void reset() {
    _motionBuffer.clear();
    _eyeOpennessBuffer.clear();
    _bboxBuffer.clear();
    _isCalibrated = false;
  }

  /// Stage 1: Baby Presence Detection
  /// Stage 2: Response Detection (Temporal Analysis)
  Future<CvAnalysisResult> analyzeFrame(CameraImage image, InputImageRotation rotation) async {
    final inputImage = _prepareInputImage(image, rotation);
    if (inputImage == null) {
      return CvAnalysisResult(babyPresent: false, presenceConfidence: 0, detectionType: AiDetectionType.none, responseConfidence: 0);
    }

    final faces = await _faceDetector.processImage(inputImage);
    
    if (faces.isEmpty) {
      // Clear buffers if baby is lost
      if (_bboxBuffer.isNotEmpty) _bboxBuffer.removeAt(0);
      return CvAnalysisResult(
        babyPresent: false, 
        presenceConfidence: 0, 
        detectionType: AiDetectionType.noBabyDetected, 
        responseConfidence: 0
      );
    }

    final face = faces.first;
    
    // 1. Presence Validation (Enhanced Heuristics)
    double presenceConfidence = _calculatePresenceConfidence(face, image.width, image.height);
    bool babyPresent = presenceConfidence > 0.85;

    if (!babyPresent) {
      return CvAnalysisResult(
        babyPresent: false, 
        presenceConfidence: presenceConfidence, 
        detectionType: AiDetectionType.noBabyDetected, 
        responseConfidence: 0
      );
    }

    // STAGE 2: RESPONSE DETECTION (Temporal)
    
    // a) Eye Openness tracking
    final double currentEyeOpenness = ((face.leftEyeOpenProbability ?? 0.5) + (face.rightEyeOpenProbability ?? 0.5)) / 2;
    _eyeOpennessBuffer.add(currentEyeOpenness);
    if (_eyeOpennessBuffer.length > _bufferSize) _eyeOpennessBuffer.removeAt(0);

    // b) Motion tracking (Euler angles)
    final double motionMetric = _calculateMotionMetric(face);
    _motionBuffer.add(motionMetric);
    if (_motionBuffer.length > _bufferSize) _motionBuffer.removeAt(0);

    // c) Bounding Box tracking (Sudden body movement/moro)
    _bboxBuffer.add(face.boundingBox);
    if (_bboxBuffer.length > _bufferSize) _bboxBuffer.removeAt(0);

    // Baseline motion learning (during idle or silent intervals)
    if (!_isCalibrated && _motionBuffer.length == _bufferSize) {
      _baselineMotion = _motionBuffer.reduce((a, b) => a + b) / _bufferSize;
      _isCalibrated = true;
    }

    AiDetectionType type = AiDetectionType.babyDetected;
    double responseConfidence = 0.0;

    // 1. Detect Blink/Eye Widening (Sudden delta in eye openness)
    if (_detectEyeEvent()) {
      type = AiDetectionType.eyeBlink;
      responseConfidence = 0.85;
    }

    // 2. Detect Sudden Motion (Moro/Startle)
    // Checks for both rapid Euler change AND bounding box shift
    final bool suddenBboxShift = _detectBboxShift();
    if (_isCalibrated && (motionMetric > (_baselineMotion * 5.0).clamp(10.0, 60.0) || suddenBboxShift)) {
      type = AiDetectionType.moroReflex;
      responseConfidence = 0.9;
    }

    // 3. Detect Head Turn (Attention shift)
    if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() > 28) {
      type = AiDetectionType.headTurn;
      responseConfidence = 0.82;
    }

    return CvAnalysisResult(
      babyPresent: true,
      presenceConfidence: presenceConfidence,
      detectionType: type,
      responseConfidence: responseConfidence,
      motionMetric: motionMetric,
    );
  }

  bool _detectBboxShift() {
    if (_bboxBuffer.length < 5) return false;
    final last = _bboxBuffer.last;
    final prev = _bboxBuffer[_bboxBuffer.length - 2];
    
    final dx = (last.center.dx - prev.center.dx).abs();
    final dy = (last.center.dy - prev.center.dy).abs();
    
    // Normalized distance shift (relative to box size)
    final shift = (dx + dy) / (last.width + last.height);
    return shift > 0.15; // 15% shift between frames is significant
  }

  double _calculatePresenceConfidence(Face face, int imgW, int imgH) {
    // A baby in BOA should be centered and relatively large in frame
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    final screenArea = imgW * imgH;
    final ratio = faceArea / screenArea;
    
    // 1. Size check: If face is too small, likely a false detection or background object
    if (ratio < 0.10) return 0.2;
    
    // 2. Center check: Face should be roughly in the middle during BOA
    final centerX = face.boundingBox.center.dx;
    final imgCenterX = imgW / 2;
    final distFromCenter = (centerX - imgCenterX).abs() / imgW;
    if (distFromCenter > 0.3) return 0.5;

    // 3. Landmarks check: Baby faces must have clear features for valid BOA
    // ML Kit returns landmarks only if enabled and detected
    if (face.landmarks.length < 4) return 0.4;
    
    // 4. Probability check: ML Kit provides "smiling" or "eyes open" prob
    // If these are null, detection quality might be low
    if (face.leftEyeOpenProbability == null && face.rightEyeOpenProbability == null) return 0.6;
    
    return 0.95;
  }

  double _calculateMotionMetric(Face face) {
    // Simple motion metric based on head rotation changes
    return (face.headEulerAngleX?.abs() ?? 0) + 
           (face.headEulerAngleY?.abs() ?? 0) + 
           (face.headEulerAngleZ?.abs() ?? 0);
  }

  bool _detectEyeEvent() {
    if (_eyeOpennessBuffer.length < 5) return false;
    final last = _eyeOpennessBuffer.last;
    final prev = _eyeOpennessBuffer[_eyeOpennessBuffer.length - 2];
    
    // Sudden change in eye openness
    return (last - prev).abs() > 0.4;
  }

  InputImage? _prepareInputImage(CameraImage image, InputImageRotation rotation) {
    try {
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      // Correctly concatenate all planes for NV21/YUV420
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
      debugPrint('[BoaCvService] prepareInputImage error: $e');
      return null;
    }
  }

  Future<void> dispose() async {
    await _faceDetector.close();
  }
}
