import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:infant_hearing_app/data/models/v2/app_user.dart';
import 'package:infant_hearing_app/data/models/v2/child.dart';
import 'package:infant_hearing_app/data/models/v2/screening.dart';
import 'package:infant_hearing_app/data/models/v2/referral.dart';
import 'package:infant_hearing_app/data/models/v2/followup.dart';

// ── Max video size allowed for upload (5 MB) ───────────────────────────────
const int _kMaxVideoBytes = 5 * 1024 * 1024; // 5 MB

/// Result returned from [AppFirestoreService.uploadScreeningMedia].
/// Distinguishes success from partial/total failure so the UI can react.
class UploadResult {
  final String? videoUrl;
  final String? pdfUrl;
  final String? videoError; // Non-null if video upload failed or was skipped
  final String? pdfError;   // Non-null if PDF upload failed

  const UploadResult({
    this.videoUrl,
    this.pdfUrl,
    this.videoError,
    this.pdfError,
  });

  bool get videoUploaded => videoUrl != null;
  bool get pdfUploaded   => pdfUrl != null;

  /// True when at least one media item failed.
  bool get hasError => videoError != null || pdfError != null;
}

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

    // Generate a human-readable child code if not already set
    // Format: BSV-MH-YYMM-XXXX  (e.g. BSV-MH-2608-4823)
    final code = child.childCode?.isNotEmpty == true
        ? child.childCode!
        : _generateChildCode();

    final newChild = child.copyWith(childId: docId, childCode: code);

    await _db.collection('children').doc(docId).set(newChild.toFirestore());
    return docId;
  }

  /// Generates a human-readable unique child code.
  /// Format: BSV-MH-YYMM-XXXX
  ///   BSV  = Baalshravya
  ///   MH   = Maharashtra (state prefix)
  ///   YYMM = 2-digit year + 2-digit month (e.g. 2608 for Aug 2026)
  ///   XXXX = 4 random digits
  String _generateChildCode() {
    final now = DateTime.now();
    final yy = now.year.toString().substring(2); // "26"
    final mm = now.month.toString().padLeft(2, '0'); // "08"
    final rand = (1000 + (now.microsecond % 9000)).toString().padLeft(4, '0');
    return 'BSV-MH-$yy$mm-$rand';
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

  // ─── Video Compression ────────────────────────────────────────────────────

  /// Compresses [videoPath] to MediumQuality (targets ~4–5 MB for a 30-60s clip).
  ///
  /// Falls back to LowQuality if the file is still over [_kMaxVideoBytes].
  /// Audio track is stripped — BOA stimuli are played through the device speaker,
  /// not recorded, so the audio channel is always silent and wasted bytes.
  ///
  /// Returns the compressed file path. The original is preserved for local ML
  /// training. The returned temp file MUST be deleted by the caller after upload.
  Future<String> _compressVideo(String videoPath) async {
    debugPrint('[AppFirestoreService] Compressing video: $videoPath');

    final MediaInfo? info = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,  // preserve original for local ML training copies
      includeAudio: false,  // BOA recordings carry no useful audio
    );

    if (info == null || info.path == null) {
      throw Exception('[AppFirestoreService] video_compress returned null — compression failed.');
    }

    final sizeBytes = File(info.path!).lengthSync();
    debugPrint('[AppFirestoreService] MediumQuality → ${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB');

    // If still >5 MB, re-compress at LowQuality
    if (sizeBytes > _kMaxVideoBytes) {
      debugPrint('[AppFirestoreService] Still >5 MB — re-compressing at LowQuality…');
      final MediaInfo? info2 = await VideoCompress.compressVideo(
        info.path!,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: false,
      );
      if (info2 == null || info2.path == null) {
        throw Exception('[AppFirestoreService] LowQuality re-compression failed.');
      }
      final size2 = File(info2.path!).lengthSync();
      debugPrint('[AppFirestoreService] LowQuality → ${(size2 / (1024 * 1024)).toStringAsFixed(2)} MB');
      return info2.path!;
    }

    return info.path!;
  }

  // ─── Media Upload ──────────────────────────────────────────────────────────

  /// Uploads compressed screening media (video and PDF) to Firebase Storage.
  ///
  /// **Video is compressed to <5 MB before upload.**
  /// Returns an [UploadResult]. Callers MUST check [UploadResult.hasError] to
  /// surface failures in the UI or schedule a background retry.
  ///
  /// This method NEVER silently swallows errors — each error is captured in
  /// [UploadResult.videoError] / [UploadResult.pdfError] so the Firestore
  /// screening document is still saved even when media upload fails.
  Future<UploadResult> uploadScreeningMedia(
    String screeningId, {
    String? videoPath,
    Uint8List? pdfBytes,
  }) async {
    String? videoUrl;
    String? pdfUrl;
    String? videoError;
    String? pdfError;
    String? compressedPath; // tracked for cleanup in finally block

    // ── 1. VIDEO ───────────────────────────────────────────────────────────
    if (videoPath != null && videoPath.isNotEmpty) {
      final sourceFile = File(videoPath);
      if (!sourceFile.existsSync()) {
        videoError = 'Video file not found on device: $videoPath';
        debugPrint('[AppFirestoreService] ⚠ $videoError');
      } else {
        try {
          compressedPath = await _compressVideo(videoPath);
          final ref = _storage.ref().child('screenings/$screeningId/video.mp4');
          final task = await ref.putFile(
            File(compressedPath),
            SettableMetadata(contentType: 'video/mp4'),
          );
          videoUrl = await task.ref.getDownloadURL();
          debugPrint('[AppFirestoreService] ✓ Video uploaded: $videoUrl');
        } catch (e, st) {
          videoError = 'Video upload failed: $e';
          debugPrint('[AppFirestoreService] ✗ $videoError\n$st');
        } finally {
          // Always delete the temp compressed file — original is kept intact
          if (compressedPath != null && compressedPath != videoPath) {
            try {
              final tmp = File(compressedPath);
              if (tmp.existsSync()) tmp.deleteSync();
              debugPrint('[AppFirestoreService] Temp compressed file cleaned up.');
            } catch (_) {}
          }
          VideoCompress.cancelCompression();
        }
      }
    }

    // ── 2. PDF ─────────────────────────────────────────────────────────────
    if (pdfBytes != null && pdfBytes.isNotEmpty) {
      try {
        final ref = _storage.ref().child('screenings/$screeningId/report.pdf');
        final task = await ref.putData(
          pdfBytes,
          SettableMetadata(contentType: 'application/pdf'),
        );
        pdfUrl = await task.ref.getDownloadURL();
        debugPrint('[AppFirestoreService] ✓ PDF uploaded: $pdfUrl');
      } catch (e, st) {
        pdfError = 'PDF upload failed: $e';
        debugPrint('[AppFirestoreService] ✗ $pdfError\n$st');
      }
    }

    return UploadResult(
      videoUrl: videoUrl,
      pdfUrl: pdfUrl,
      videoError: videoError,
      pdfError: pdfError,
    );
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
