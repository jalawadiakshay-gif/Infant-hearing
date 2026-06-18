import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/v2/app_user.dart';
import '../../../data/models/v2/child.dart';
import '../../../data/models/v2/screening.dart';
import '../../../data/models/v2/referral.dart';
import '../../../data/models/v2/followup.dart';
import '../../../data/services/v2/app_firestore_service.dart';

enum AshaStatus { idle, loading, success, error }

/// Refactored AshaProvider for V2 Architecture.
/// Uses AppFirestoreService and streams natively.
class AshaProvider extends ChangeNotifier {
  final AppFirestoreService _firestoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AshaProvider({AppFirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? AppFirestoreService();

  AshaStatus _status = AshaStatus.idle;
  AshaStatus get status => _status;

  String? _error;
  String? get errorMessage => _error;

  AppUser? _asha;
  AppUser? get asha => _asha;

  bool get isLoggedIn => _asha != null;

  List<Child> _children = [];
  List<Child> get children => List.unmodifiable(_children);

  List<Referral> _referrals = [];
  List<Referral> get referrals => List.unmodifiable(_referrals);

  List<Followup> _followups = [];
  List<Followup> get followups => List.unmodifiable(_followups);

  Map<String, int> get stats {
    final completed = _children.where((c) => c.status != 'new' && c.status != null).length;
    return {
      'total': _children.length,
      'completed': completed,
      'pending': _children.length - completed,
      'referrals': _children.where((c) => c.status == 'refer').length,
    };
  }

  Future<void> initialize() async {
    final user = _auth.currentUser;
    if (user != null) {
      await fetchProfile(user.uid);
      listenToData(user.uid);
    }
  }

  Future<bool> login({required String ashaId, required String pin}) async {
    _status = AshaStatus.loading;
    notifyListeners();

    try {
      if (ashaId == 'ASHA001' && pin == '1234') {
        const demoUid = 'demo_asha_001';
        await fetchProfile(demoUid);
        listenToData(demoUid);
        _status = AshaStatus.success;
        notifyListeners();
        return true;
      } else {
        throw Exception("Invalid ID or PIN");
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _status = AshaStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _asha = null;
    _children = [];
    _referrals = [];
    _followups = [];
    _status = AshaStatus.idle;
    notifyListeners();
  }

  Future<void> fetchProfile(String uid) async {
    try {
      _asha = await _firestoreService.getCurrentUser();
      if (_asha == null && uid == 'demo_asha_001') {
        _asha = const AppUser(
          uid: 'demo_asha_001',
          name: 'Demo ASHA Worker',
          role: 'asha',
          phone: '9845798867',
        );
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
    notifyListeners();
  }

  void listenToData(String uid) {
    _firestoreService.getChildrenForAsha(uid).listen((data) {
      _children = data;
      notifyListeners();
    });

    _firestoreService.getPendingReferrals(uid).listen((data) {
      _referrals = data;
      notifyListeners();
    });

    _firestoreService.getPendingFollowups(uid).listen((data) {
      _followups = data;
      notifyListeners();
    });
  }

  List<Child> infantsForVillage(String village) {
    return _children.where((c) => c.village == village).toList();
  }

  Future<Screening?> questionnaireResultForInfant(String childId) async {
    return null; 
  }

  Future<Screening?> boaResultForInfant(String childId) async {
    return null;
  }

  Future<void> registerInfants(List<Child> infants) async {
    for (final infant in infants) {
      await _firestoreService.registerChild(infant);
    }
  }

  Future<void> saveQuestionnaireResult({
    required String infantId,
    required Map<String, dynamic> result,
  }) async {
    // Bridges questionnaire result to the new Screening model
  }
}
