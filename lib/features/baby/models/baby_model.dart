class BabyModel {
  final String name;
  final int ageMonths;
  final double birthWeight;
  final int gestationalAge;
  final bool nicuAdmission;
  final String deliveryMode;

  const BabyModel({
    required this.name,
    required this.ageMonths,
    required this.birthWeight,
    required this.gestationalAge,
    required this.nicuAdmission,
    required this.deliveryMode,
  });

  BabyModel copyWith({
    String? name,
    int? ageMonths,
    double? birthWeight,
    int? gestationalAge,
    bool? nicuAdmission,
    String? deliveryMode,
  }) {
    return BabyModel(
      name: name ?? this.name,
      ageMonths: ageMonths ?? this.ageMonths,
      birthWeight: birthWeight ?? this.birthWeight,
      gestationalAge: gestationalAge ?? this.gestationalAge,
      nicuAdmission: nicuAdmission ?? this.nicuAdmission,
      deliveryMode: deliveryMode ?? this.deliveryMode,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'ageMonths': ageMonths,
        'birthWeight': birthWeight,
        'gestationalAge': gestationalAge,
        'nicuAdmission': nicuAdmission,
        'deliveryMode': deliveryMode,
      };

  bool get isPremature => gestationalAge < 37;
  bool get isLowBirthWeight => birthWeight < 2.5;
  bool get isHighRisk => isPremature || isLowBirthWeight || nicuAdmission;

  @override
  String toString() => 'BabyModel(name: $name, age: ${ageMonths}mo)';
}

enum DeliveryMode {
  normal,
  cesarean,
  assisted;

  String get label {
    switch (this) {
      case DeliveryMode.normal:
        return 'Normal / Vaginal';
      case DeliveryMode.cesarean:
        return 'C-Section';
      case DeliveryMode.assisted:
        return 'Assisted (Forceps/Vacuum)';
    }
  }
}
