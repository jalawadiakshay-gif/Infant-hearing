import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified model for all humans in the system (ASHA, Parent, Clinician, Admin).
/// Replaces legacy UserModel, AshaWorkerModel, AshaModel.
class AppUser {
  final String uid;
  final String name;
  final String phone;
  final String role; // 'asha', 'parent', 'clinician', 'admin'
  final String lang; // 'en', 'hi', 'kn', 'mr'
  final String? district;
  final String? village;
  final String? fcmToken;
  final String? email;
  final String? relationshipToChild;
  final String? emergencyContact;
  final String? preferredHospital;
  final String? detailedAddress;
  final String? city;
  final String? state;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    this.lang = 'en',
    this.district,
    this.village,
    this.fcmToken,
    this.email,
    this.relationshipToChild,
    this.emergencyContact,
    this.preferredHospital,
    this.detailedAddress,
    this.city,
    this.state,
    this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'parent',
      lang: data['lang'] ?? 'en',
      district: data['district'],
      village: data['village'],
      fcmToken: data['fcmToken'],
      email: data['email'],
      relationshipToChild: data['relationshipToChild'],
      emergencyContact: data['emergencyContact'],
      preferredHospital: data['preferredHospital'],
      detailedAddress: data['detailedAddress'],
      city: data['city'],
      state: data['state'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'lang': lang,
      'district': district,
      'village': village,
      'fcmToken': fcmToken,
      'email': email,
      'relationshipToChild': relationshipToChild,
      'emergencyContact': emergencyContact,
      'preferredHospital': preferredHospital,
      'detailedAddress': detailedAddress,
      'city': city,
      'state': state,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? name,
    String? phone,
    String? role,
    String? lang,
    String? district,
    String? village,
    String? fcmToken,
    String? email,
    String? relationshipToChild,
    String? emergencyContact,
    String? preferredHospital,
    String? detailedAddress,
    String? city,
    String? state,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      lang: lang ?? this.lang,
      district: district ?? this.district,
      village: village ?? this.village,
      fcmToken: fcmToken ?? this.fcmToken,
      email: email ?? this.email,
      relationshipToChild: relationshipToChild ?? this.relationshipToChild,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      preferredHospital: preferredHospital ?? this.preferredHospital,
      detailedAddress: detailedAddress ?? this.detailedAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      createdAt: createdAt,
    );
  }

  bool get isAsha => role == 'asha';
  bool get isAdmin => role == 'admin';
  bool get isClinician => role == 'clinician';
  bool get isParent => role == 'parent';

  String get userId => uid; // Alias for backward compatibility

  @override
  String toString() => 'AppUser(uid: $uid, name: $name, role: $role)';
}
