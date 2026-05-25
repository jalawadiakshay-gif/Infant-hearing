class BabyModel {
  final String name;
  final String gender;
  final double birthWeight;
  final int gestationalAge;
  final bool nicuAdmission;
  final String deliveryMode;
  final String? medicalNotes;
  final DateTime dob;

  const BabyModel({
    required this.name,
    required this.gender,
    required this.birthWeight,
    required this.gestationalAge,
    required this.nicuAdmission,
    required this.deliveryMode,
    required this.dob,
    this.medicalNotes,
  });

  int get ageMonths {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + now.month - dob.month;
    if (now.day < dob.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  String get age => '$ageMonths months';

  BabyModel copyWith({
    String? name,
    String? gender,
    double? birthWeight,
    int? gestationalAge,
    bool? nicuAdmission,
    String? deliveryMode,
    String? medicalNotes,
    DateTime? dob,
  }) {
    return BabyModel(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthWeight: birthWeight ?? this.birthWeight,
      gestationalAge: gestationalAge ?? this.gestationalAge,
      nicuAdmission: nicuAdmission ?? this.nicuAdmission,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      dob: dob ?? this.dob,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'gender': gender,
        'birthWeight': birthWeight,
        'gestationalAge': gestationalAge,
        'nicuAdmission': nicuAdmission,
        'deliveryMode': deliveryMode,
        'medicalNotes': medicalNotes,
        'dob': dob.toIso8601String(),
      };

  bool get isPremature => gestationalAge < 37;
  bool get isLowBirthWeight => birthWeight < 2.5;
  bool get isHighRisk => isPremature || isLowBirthWeight || nicuAdmission;

  String get riskLevel {
    int score = 0;
    if (isPremature) score++;
    if (isLowBirthWeight) score++;
    if (nicuAdmission) score++;
    
    if (score == 0) return 'Low';
    if (score == 1) return 'Medium';
    return 'High';
  }

  @override
  String toString() => 'BabyModel(name: $name, dob: ${dob.toIso8601String()}, gender: $gender)';
}
