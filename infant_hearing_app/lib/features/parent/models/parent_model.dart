class ParentModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String address;
  final String city;
  final String state;
  final String emergencyContact;
  final String relationship; // Mother / Father / Guardian
  final String? bloodGroup;
  final String? preferredHospital;
  final bool isVerified;

  String get contactNumber => phone;

  const ParentModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.emergencyContact,
    required this.relationship,
    this.bloodGroup,
    this.preferredHospital,
    this.isVerified = false,
  });

  ParentModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? emergencyContact,
    String? relationship,
    String? bloodGroup,
    String? preferredHospital,
    bool? isVerified,
  }) {
    return ParentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      relationship: relationship ?? this.relationship,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      preferredHospital: preferredHospital ?? this.preferredHospital,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'state': state,
        'emergencyContact': emergencyContact,
        'relationship': relationship,
        'bloodGroup': bloodGroup,
        'preferredHospital': preferredHospital,
        'isVerified': isVerified,
      };
}
