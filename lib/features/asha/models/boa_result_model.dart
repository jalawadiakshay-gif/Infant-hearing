enum BoaResponse { present, absent, inconclusive }

extension BoaResponseExtension on BoaResponse {
  String get label {
    switch (this) {
      case BoaResponse.present:
        return 'Present';
      case BoaResponse.absent:
        return 'Absent';
      case BoaResponse.inconclusive:
        return 'Inconclusive';
    }
  }

  String get interpretation {
    switch (this) {
      case BoaResponse.present:
        return 'Infant showed a behavioural response to sound stimulus. Hearing appears functional.';
      case BoaResponse.absent:
        return 'No behavioural response observed. Refer for formal audiological evaluation.';
      case BoaResponse.inconclusive:
        return 'Response was unclear. Repeat the BOA test after 2 weeks.';
    }
  }
}

class BoaResultModel {
  final String infantId;
  final String infantName;
  final String ashaId;
  final BoaResponse leftEar;
  final BoaResponse rightEar;
  final String? notes;
  final DateTime testedAt;

  const BoaResultModel({
    required this.infantId,
    required this.infantName,
    required this.ashaId,
    required this.leftEar,
    required this.rightEar,
    this.notes,
    required this.testedAt,
  });

  Map<String, dynamic> toMap() => {
        'infantId': infantId,
        'infantName': infantName,
        'ashaId': ashaId,
        'leftEar': leftEar.name,
        'rightEar': rightEar.name,
        'notes': notes,
        'testedAt': testedAt.toIso8601String(),
      };

  @override
  String toString() =>
      'BoaResultModel(infantId: $infantId, left: $leftEar, right: $rightEar)';
}