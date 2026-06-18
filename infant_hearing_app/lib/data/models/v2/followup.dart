import 'package:cloud_firestore/cloud_firestore.dart';

/// Unified model for a Followup visit.
/// Stored in a separate 'followups' collection to allow multiple followups per child.
class Followup {
  final String followupId;
  final String childId;
  final String ashaId;
  final String? screeningId; // The screening that triggered this followup (optional)
  final DateTime visitDate;
  final bool completed;
  final DateTime? completedAt;
  final String? notes;
  final DateTime? createdAt;

  const Followup({
    required this.followupId,
    required this.childId,
    required this.ashaId,
    this.screeningId,
    required this.visitDate,
    this.completed = false,
    this.completedAt,
    this.notes,
    this.createdAt,
  });

  factory Followup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Followup(
      followupId: doc.id,
      childId: data['childId'] ?? '',
      ashaId: data['ashaId'] ?? '',
      screeningId: data['screeningId'],
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      completed: data['completed'] ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'childId': childId,
      'ashaId': ashaId,
      if (screeningId != null) 'screeningId': screeningId,
      'visitDate': Timestamp.fromDate(visitDate),
      'completed': completed,
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (notes != null) 'notes': notes,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Followup copyWith({
    String? ashaId,
    DateTime? visitDate,
    bool? completed,
    DateTime? completedAt,
    String? notes,
  }) {
    return Followup(
      followupId: followupId,
      childId: childId,
      ashaId: ashaId ?? this.ashaId,
      screeningId: screeningId,
      visitDate: visitDate ?? this.visitDate,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  bool get isOverdue => !completed && visitDate.isBefore(DateTime.now());

  @override
  String toString() => 'Followup(id: $followupId, date: $visitDate, completed: $completed)';
}
