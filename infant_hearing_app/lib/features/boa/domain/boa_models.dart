import 'package:flutter/material.dart';

/// BOA Domain Models
/// Based on JNMC-specified adaptive dB protocol (70 → 45/90 dB HL).

// ── Stimulus frequency options ────────────────────────────────────────────────
enum BoaFrequency {
  freq1kHz,
  freq3kHz,
  broadbandNoise,
  warbleTone;

  String get label {
    switch (this) {
      case BoaFrequency.freq1kHz:       return '1 kHz';
      case BoaFrequency.freq3kHz:       return '3 kHz';
      case BoaFrequency.broadbandNoise: return 'Broadband Noise';
      case BoaFrequency.warbleTone:     return 'Warble Tone';
    }
  }
}

// ── dB levels in the adaptive protocol ───────────────────────────────────────
enum BoaDbLevel {
  db70,
  db45,
  db90;

  int get value {
    switch (this) {
      case BoaDbLevel.db70: return 70;
      case BoaDbLevel.db45: return 45;
      case BoaDbLevel.db90: return 90;
    }
  }

  String get label => '${value} dB HL';

  String get clinicalNote {
    switch (this) {
      case BoaDbLevel.db70:
        return 'Initial stimulus. ~90% of infants with normal hearing respond at this level.';
      case BoaDbLevel.db45:
        return 'Reduced level. Response here indicates good hearing sensitivity.';
      case BoaDbLevel.db90:
        return 'Elevated stimulus. No response at this level is a strong indicator of hearing impairment.';
    }
  }

  /// Asset path for the pre-calibrated WAV file for this level.
  String get assetPath {
    switch (this) {
      case BoaDbLevel.db45: return 'assets/audio/boa_45db.wav';
      case BoaDbLevel.db70: return 'assets/audio/boa_70db.wav';
      case BoaDbLevel.db90: return 'assets/audio/boa_90db.wav';
    }
  }
}

// ── Caregiver-observed response ───────────────────────────────────────────────
enum BoaResponse {
  responseDetected,
  noResponse,
  uncertain;

  String get label {
    switch (this) {
      case BoaResponse.responseDetected: return 'Response Detected';
      case BoaResponse.noResponse:       return 'No Response';
      case BoaResponse.uncertain:        return 'Uncertain';
    }
  }
}

// ── BOA test phases ───────────────────────────────────────────────────────────
enum BoaTestPhase {
  idle,
  checklist,
  calibration,   // Random pre-stimulus delay (1–3s)
  infantDetection,
  baselineLearning,
  playing,       // Stimulus actively playing
  awaitingResponse, // Stimulus done, observing
  catchTrial,    // Silent trial
  complete;
}

// ── AI Detection Types ────────────────────────────────────────────────────────
enum AiDetectionType {
  none,
  babyDetected,
  noBabyDetected,
  eyeBlink,
  headTurn,
  moroReflex,
  bodyMovement,
  suckingChange,
  positionBaby;
}

// ── Response confidence classification ───────────────────────────────────────
enum ResponseStrength {
  none,
  weak,
  probable,
  strong;

  String get label {
    switch (this) {
      case ResponseStrength.none:     return 'No Reliable Response';
      case ResponseStrength.weak:     return 'Weak Response';
      case ResponseStrength.probable: return 'Probable Response';
      case ResponseStrength.strong:   return 'Strong Response';
    }
  }
}

// ── Final BOA outcome ─────────────────────────────────────────────────────────
enum BoaOutcome {
  favorableHearingResponse,
  monitor,
  suspectedHearingLoss;

  String get label {
    switch (this) {
      case BoaOutcome.favorableHearingResponse: return 'Favorable Hearing Response';
      case BoaOutcome.monitor:                  return 'Monitor';
      case BoaOutcome.suspectedHearingLoss:     return 'Suspected Hearing Loss';
    }
  }

  String get explanation {
    switch (this) {
      case BoaOutcome.favorableHearingResponse:
        return 'The infant demonstrated consistent behavioral responses to calibrated sound stimuli '
            'at 45 dB HL, indicating good hearing sensitivity. This is a favorable behavioral '
            'screening result.';
      case BoaOutcome.monitor:
        return 'The infant showed some responses but the pattern requires monitoring. '
            'A repeat screening is recommended within 4 weeks.';
      case BoaOutcome.suspectedHearingLoss:
        return 'The infant did not demonstrate clear behavioral responses even at 90 dB HL. '
            'This is a significant indicator of possible moderate-to-severe hearing impairment. '
            'Immediate formal diagnostic evaluation is strongly recommended.';
    }
  }

  String get recommendation {
    switch (this) {
      case BoaOutcome.favorableHearingResponse:
        return 'Continue routine developmental monitoring. Schedule next screening at 3 months.';
      case BoaOutcome.monitor:
        return 'Repeat the BOA screening in 4 weeks. If concerns persist, refer for OAE testing.';
      case BoaOutcome.suspectedHearingLoss:
        return 'Refer immediately for formal diagnostic audiological evaluation including '
            'OAE, ABR, and/or ASSR testing at JNMC Audiology Department.';
    }
  }
}

// ── Single trial record ───────────────────────────────────────────────────────
class BoaTrial {
  final BoaDbLevel dbLevel;
  final BoaFrequency frequency;
  final BoaResponse response;
  final DateTime timestamp;
  final bool isCatchTrial;
  final double aiConfidence;
  final AiDetectionType aiDetection;

  const BoaTrial({
    required this.dbLevel,
    required this.frequency,
    required this.response,
    required this.timestamp,
    this.isCatchTrial = false,
    this.aiConfidence = 0.0,
    this.aiDetection = AiDetectionType.none,
  });
}

// ── Pre-test checklist item ───────────────────────────────────────────────────
class BoaChecklistItem {
  final String id;
  final String title;
  final String description;
  final IconData? icon;
  bool isChecked;

  BoaChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
    this.isChecked = false,
  });
}
