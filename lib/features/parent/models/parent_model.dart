class ParentModel {
  final String name;
  final int age;
  final String gender;
  final String contactNumber;
  final String address;

  const ParentModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.contactNumber,
    required this.address,
  });

  ParentModel copyWith({
    String? name,
    int? age,
    String? gender,
    String? contactNumber,
    String? address,
  }) {
    return ParentModel(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'age': age,
        'gender': gender,
        'contactNumber': contactNumber,
        'address': address,
      };

  @override
  String toString() => 'ParentModel(name: $name, age: $age, gender: $gender)';
}

enum Gender {
  male,
  female,
  other,
  preferNotToSay;

  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}
