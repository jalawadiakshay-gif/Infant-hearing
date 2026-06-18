import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified model for an infant/child registered in the system.
/// Replaces legacy BabyModel and ChildModel.
class Child {
  final String childId;
  final String name;
  final DateTime dob;
  final String gender; // 'M', 'F', 'O'
  final String parentName;
  final String parentPhone;
  final String? village;
  final String createdBy; // UID of ASHA worker
  
  // Birth Details & Medical Information
  final double? birthWeight;
  final int? gestationalAge;
  final String? birthType;

  // Risk factors
  final bool riskNicu;
  final int? nicuDuration;

  // Hospital
  final String? hospitalName;
  final String? pediatricianName;

  // Screening status input
  final String? hearingScreeningStatus;

  // Denormalized data
  final DateTime? lastScreeningDate;
  final String? lastScreeningType; // 'q', 'boa'
  final String? lastScreeningResult; // 'pass', 'refer', 'monitor'
  final String? status; // 'new', 'pass', 'refer', 'monitor'
  
  // Embedded followup (max 1 active followup)
  final DateTime? followupDate;
  final String? followupNotes;
  final bool? followupDone;

  final DateTime? createdAt;

  const Child({
    required this.childId,
    required this.name,
    required this.dob,
    required this.gender,
    required this.parentName,
    required this.parentPhone,
    this.village,
    required this.createdBy,
    this.birthWeight,
    this.gestationalAge,
    this.birthType,
    this.riskNicu = false,
    this.nicuDuration,
    this.hospitalName,
    this.pediatricianName,
    this.hearingScreeningStatus,
    this.lastScreeningDate,
    this.lastScreeningType,
    this.lastScreeningResult,
    this.status,
    this.followupDate,
    this.followupNotes,
    this.followupDone,
    this.createdAt,
  });

  factory Child.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse nested risk map
    final risk = data['risk'] as Map<String, dynamic>? ?? {};
    
    // Parse nested lastScreening map
    final last = data['lastScreening'] as Map<String, dynamic>?;
    
    // Parse nested followup map
    final fu = data['followup'] as Map<String, dynamic>?;

    return Child(
      childId: doc.id,
      name: data['name'] ?? '',
      dob: (data['dob'] as Timestamp).toDate(),
      gender: data['gender'] ?? '',
      parentName: data['parentName'] ?? '',
      parentPhone: data['parentPhone'] ?? '',
      village: data['village'],
      createdBy: data['createdBy'] ?? '',
      birthWeight: (data['birthWeight'] as num?)?.toDouble(),
      gestationalAge: data['gestationalAge'] as int?,
      birthType: data['birthType'] as String?,
      riskNicu: risk['nicu'] ?? false,
      nicuDuration: risk['nicuDuration'] as int?,
      hospitalName: data['hospitalName'] as String?,
      pediatricianName: data['pediatricianName'] as String?,
      hearingScreeningStatus: data['hearingScreeningStatus'] as String?,
      lastScreeningDate: (last?['date'] as Timestamp?)?.toDate(),
      lastScreeningType: last?['type'],
      lastScreeningResult: last?['result'],
      status: data['status'],
      followupDate: (fu?['date'] as Timestamp?)?.toDate(),
      followupNotes: fu?['notes'],
      followupDone: fu?['done'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'dob': Timestamp.fromDate(dob),
      'gender': gender,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'village': village,
      'createdBy': createdBy,
      'birthWeight': birthWeight,
      'gestationalAge': gestationalAge,
      'birthType': birthType,
      'hospitalName': hospitalName,
      'pediatricianName': pediatricianName,
      'hearingScreeningStatus': hearingScreeningStatus,
      'risk': {
        'nicu': riskNicu,
        'nicuDuration': nicuDuration,
      },
      if (lastScreeningDate != null) 'lastScreening': {
        'date': Timestamp.fromDate(lastScreeningDate!),
        'type': lastScreeningType,
        'result': lastScreeningResult,
      },
      if (status != null) 'status': status,
      if (followupDate != null) 'followup': {
        'date': Timestamp.fromDate(followupDate!),
        'notes': followupNotes,
        'done': followupDone ?? false,
      },
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Child copyWith({
    String? childId,
    String? name,
    DateTime? dob,
    String? gender,
    String? parentName,
    String? parentPhone,
    String? village,
    double? birthWeight,
    int? gestationalAge,
    String? birthType,
    bool? riskNicu,
    int? nicuDuration,
    String? hospitalName,
    String? pediatricianName,
    String? hearingScreeningStatus,
    DateTime? lastScreeningDate,
    String? lastScreeningType,
    String? lastScreeningResult,
    String? status,
    DateTime? followupDate,
    String? followupNotes,
    bool? followupDone,
  }) {
    return Child(
      childId: childId ?? this.childId,
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      village: village ?? this.village,
      createdBy: createdBy,
      birthWeight: birthWeight ?? this.birthWeight,
      gestationalAge: gestationalAge ?? this.gestationalAge,
      birthType: birthType ?? this.birthType,
      riskNicu: riskNicu ?? this.riskNicu,
      nicuDuration: nicuDuration ?? this.nicuDuration,
      hospitalName: hospitalName ?? this.hospitalName,
      pediatricianName: pediatricianName ?? this.pediatricianName,
      hearingScreeningStatus: hearingScreeningStatus ?? this.hearingScreeningStatus,
      lastScreeningDate: lastScreeningDate ?? this.lastScreeningDate,
      lastScreeningType: lastScreeningType ?? this.lastScreeningType,
      lastScreeningResult: lastScreeningResult ?? this.lastScreeningResult,
      status: status ?? this.status,
      followupDate: followupDate ?? this.followupDate,
      followupNotes: followupNotes ?? this.followupNotes,
      followupDone: followupDone ?? this.followupDone,
      createdAt: createdAt,
    );
  }

  int get ageMonths {
    final now = DateTime.now();
    int months = (now.year - dob.year) * 12 + now.month - dob.month;
    if (now.day < dob.day) months--;
    return months < 0 ? 0 : months;
  }

  @override
  String toString() => 'Child(id: $childId, name: $name)';
}
