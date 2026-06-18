import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified model for a Referral.
/// Stored in a separate 'referrals' collection to track workflow lifecycle.
class Referral {
  final String referralId;
  final String childId;
  final String ashaId;
  final String screeningId; // The screening that triggered this referral
  final String reason;
  final String hospital;
  final String status; // 'pending', 'scheduled', 'visited', 'tested', 'resolved'
  final DateTime date;
  final String? notes;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  const Referral({
    required this.referralId,
    required this.childId,
    required this.ashaId,
    required this.screeningId,
    required this.reason,
    required this.hospital,
    required this.status,
    required this.date,
    this.notes,
    this.updatedAt,
    this.createdAt,
  });

  factory Referral.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Referral(
      referralId: doc.id,
      childId: data['childId'] ?? '',
      ashaId: data['ashaId'] ?? '',
      screeningId: data['screeningId'] ?? '',
      reason: data['reason'] ?? '',
      hospital: data['hospital'] ?? '',
      status: data['status'] ?? 'pending',
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'childId': childId,
      'ashaId': ashaId,
      'screeningId': screeningId,
      'reason': reason,
      'hospital': hospital,
      'status': status,
      'date': Timestamp.fromDate(date),
      if (notes != null) 'notes': notes,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Referral copyWith({
    String? ashaId,
    String? reason,
    String? hospital,
    String? status,
    String? notes,
  }) {
    return Referral(
      referralId: referralId,
      childId: childId,
      ashaId: ashaId ?? this.ashaId,
      screeningId: screeningId,
      reason: reason ?? this.reason,
      hospital: hospital ?? this.hospital,
      status: status ?? this.status,
      date: date,
      notes: notes ?? this.notes,
      updatedAt: DateTime.now(),
      createdAt: createdAt,
    );
  }

  bool get isPending => status == 'pending';
  bool get isResolved => status == 'resolved';

  @override
  String toString() => 'Referral(id: $referralId, status: $status)';
}
