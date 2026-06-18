import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:infant_hearing_app/data/models/v2/app_user.dart';
import 'package:infant_hearing_app/data/models/v2/child.dart';
import 'package:infant_hearing_app/data/models/v2/screening.dart';
import 'package:infant_hearing_app/data/models/v2/referral.dart';
import 'package:infant_hearing_app/data/models/v2/followup.dart';

/// Unified Firestore service for the Baalshravya app.
/// Replaces FirestoreService, AshaFirestoreService, and all ApiServices.
/// Uses native Firestore offline capabilities (no custom sync queue).
class AppFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // ─── Users ─────────────────────────────────────────────────────────────────

  /// Get the current user's profile
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Create or update user profile
  Future<void> saveUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(
          user.toFirestore(),
          SetOptions(merge: true),
        );
  }

  // ─── Children ──────────────────────────────────────────────────────────────

  /// Get stream of children for a specific ASHA worker
  Stream<List<Child>> getChildrenForAsha(String ashaUid) {
    return _db
        .collection('children')
        .where('createdBy', isEqualTo: ashaUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Child.fromFirestore(doc))
            .toList());
  }

  /// Register a new child
  Future<String> registerChild(Child child) async {
    // Generate UUID if not provided (idempotency for offline retries)
    final docId = child.childId.isEmpty ? _uuid.v4() : child.childId;
    
    final newChild = child.childId.isEmpty 
        ? child.copyWith(childId: docId) 
        : child;

    await _db.collection('children').doc(docId).set(newChild.toFirestore());
    return docId;
  }

  /// Update child status/last screening after a screening
  Future<void> updateChildScreeningStatus(
    String childId, {
    required String result,
    required String type,
  }) async {
    await _db.collection('children').doc(childId).set({
      'status': result,
      'lastScreening': {
        'date': FieldValue.serverTimestamp(),
        'type': type,
        'result': result,
      }
    }, SetOptions(merge: true));
  }

  // ─── Screenings ────────────────────────────────────────────────────────────

  /// Get screening history for a child
  Stream<List<Screening>> getScreeningsForChild(String childId) {
    return _db
        .collection('screenings')
        .where('childId', isEqualTo: childId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Screening.fromFirestore(doc))
            .toList());
  }

  /// Submit a new screening (BOA or Questionnaire)
  Future<String> submitScreening(Screening screening) async {
    final docId = screening.screeningId.isEmpty ? _uuid.v4() : screening.screeningId;
    
    final newScreening = screening.screeningId.isEmpty 
        ? Screening(
            screeningId: docId,
            childId: screening.childId,
            conductedBy: screening.conductedBy,
            type: screening.type,
            result: screening.result,
            date: screening.date,
            isOffline: screening.isOffline,
            clipPath: screening.clipPath,
            createdAt: screening.createdAt,
            qAnswers: screening.qAnswers,
            qScore: screening.qScore,
            qRiskPct: screening.qRiskPct,
            qAgeMonths: screening.qAgeMonths,
            boaOutcome: screening.boaOutcome,
            boaNoiseDb: screening.boaNoiseDb,
            boaTrials: screening.boaTrials,
          )
        : screening;

    await _db.collection('screenings').doc(docId).set(newScreening.toFirestore());
    
    // Auto-update child status
    await updateChildScreeningStatus(
      screening.childId,
      result: screening.result,
      type: screening.type,
    );
    
    return docId;
  }

  /// Update clip path for a screening
  Future<void> updateScreeningClipPath(String screeningId, String clipPath) async {
    await _db.collection('screenings').doc(screeningId).update({
      'clipPath': clipPath,
    });
  }

  /// Uploads screening media (video and pdf) to Firebase Storage
  /// Returns a map with 'videoUrl' and 'pdfUrl'
  Future<Map<String, String>> uploadScreeningMedia(
    String screeningId, {
    String? videoPath,
    Uint8List? pdfBytes,
  }) async {
    final urls = <String, String>{};

    try {
      if (videoPath != null && videoPath.isNotEmpty) {
        final ref = _storage.ref().child('screenings/$screeningId/video.mp4');
        final file = File(videoPath);
        if (file.existsSync()) {
          final uploadTask = await ref.putFile(
            file, 
            SettableMetadata(contentType: 'video/mp4'),
          );
          urls['videoUrl'] = await uploadTask.ref.getDownloadURL();
        }
      }

      if (pdfBytes != null && pdfBytes.isNotEmpty) {
        final ref = _storage.ref().child('screenings/$screeningId/report.pdf');
        final uploadTask = await ref.putData(
          pdfBytes,
          SettableMetadata(contentType: 'application/pdf'),
        );
        urls['pdfUrl'] = await uploadTask.ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('[AppFirestoreService] Media upload error: $e');
      // If upload fails, we swallow it here so the screening can still submit
      // In production, we might want to throw or queue for retry
    }

    return urls;
  }

  // ─── Referrals ─────────────────────────────────────────────────────────────

  /// Get pending referrals for an ASHA worker
  Stream<List<Referral>> getPendingReferrals(String ashaUid) {
    return _db
        .collection('referrals')
        .where('ashaId', isEqualTo: ashaUid)
        .where('status', isEqualTo: 'pending')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Referral.fromFirestore(doc))
            .toList());
  }

  /// Get all referrals for a child
  Stream<List<Referral>> getReferralsForChild(String childId) {
    return _db
        .collection('referrals')
        .where('childId', isEqualTo: childId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Referral.fromFirestore(doc))
            .toList());
  }

  /// Create a new referral
  Future<String> createReferral(Referral referral) async {
    final docId = referral.referralId.isEmpty ? _uuid.v4() : referral.referralId;
    
    final data = referral.toFirestore();
    await _db.collection('referrals').doc(docId).set(data);
    return docId;
  }

  /// Update referral status
  Future<void> updateReferralStatus(String referralId, String status, {String? notes}) async {
    final updates = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (notes != null) updates['notes'] = notes;
    
    await _db.collection('referrals').doc(referralId).update(updates);
  }

  // ─── Followups ─────────────────────────────────────────────────────────────

  /// Get upcoming/overdue followups for an ASHA worker
  Stream<List<Followup>> getPendingFollowups(String ashaUid) {
    return _db
        .collection('followups')
        .where('ashaId', isEqualTo: ashaUid)
        .where('completed', isEqualTo: false)
        .orderBy('visitDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Followup.fromFirestore(doc))
            .toList());
  }

  /// Schedule a new followup
  Future<String> scheduleFollowup(Followup followup) async {
    final docId = followup.followupId.isEmpty ? _uuid.v4() : followup.followupId;
    final data = followup.toFirestore();
    await _db.collection('followups').doc(docId).set(data);
    return docId;
  }

  /// Mark followup as completed
  Future<void> completeFollowup(String followupId, {String? notes}) async {
    final updates = <String, dynamic>{
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
    };
    if (notes != null) updates['notes'] = notes;
    
    await _db.collection('followups').doc(followupId).update(updates);
  }
}
