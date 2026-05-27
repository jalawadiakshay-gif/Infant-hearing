import 'package:flutter/material.dart';
import '../models/asha_model.dart';
import '../models/boa_result_model.dart';

enum AshaStatus { idle, loading, success, error }

class AshaProvider extends ChangeNotifier {
  AshaModel? _asha;
  AshaStatus _status = AshaStatus.idle;
  String? _errorMessage;

  // In-memory store (Phase 1 — no backend)
  final List<AshaModel> _registeredAshaWorkers = [
    AshaModel(
      ashaId: 'ASHA001',
      name: 'Sunita Devi',
      pin: '1234',
      phoneNumber: '9876543210',
      assignedVillages: ['Rampur', 'Sitapur', 'Laxmipur'],
      assignedInfantIds: ['INF001', 'INF002', 'INF003', 'INF004'],
    ),
  ];

  // Mock Infant Data
  final Map<String, List<Map<String, dynamic>>> _villageInfants = {
    'Rampur': [
      {'id': 'INF001', 'name': 'Aarav Kumar', 'ageMonths': 2, 'gender': 'Male', 'status': 'Pending', 'registeredAt': '2025-03-10T09:00:00.000'},
      {'id': 'INF002', 'name': 'Ishani Singh', 'ageMonths': 4, 'gender': 'Female', 'status': 'Completed', 'registeredAt': '2025-03-15T10:30:00.000'},
    ],
    'Sitapur': [
      {'id': 'INF003', 'name': 'Vihaan Gupta', 'ageMonths': 1, 'gender': 'Male', 'status': 'Follow-up', 'registeredAt': '2025-04-01T08:00:00.000'},
    ],
    'Laxmipur': [
      {'id': 'INF004', 'name': 'Ananya Reddy', 'ageMonths': 3, 'gender': 'Female', 'status': 'Pending', 'registeredAt': '2025-04-05T11:00:00.000'},
    ],
  };

  // BOA results stored by infantId
  final Map<String, BoaResultModel> _boaResults = {};

  // Questionnaire results
  final Map<String, Map<String, dynamic>> _questionnaireResults = {};

  // Screening Stats
  Map<String, int> get stats => {
    'total': 124,
    'completed': 98,
    'pending': 26,
    'referrals': 5,
  };

  // ── Getters ────────────────────────────────────────────────────────────────
  AshaModel? get asha => _asha;
  AshaStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _asha != null;

  List<String> get assignedVillages => _asha?.assignedVillages ?? [];

  List<Map<String, dynamic>> infantsForVillage(String village) =>
      _villageInfants[village] ?? [];

  List<Map<String, dynamic>> get allInfants {
    List<Map<String, dynamic>> all = [];
    _villageInfants.values.forEach((list) => all.addAll(list));
    return all;
  }

  List<Map<String, dynamic>> get pendingScreenings => 
      allInfants.where((i) => i['status'] == 'Pending').toList();

  BoaResultModel? boaResultForInfant(String infantId) => _boaResults[infantId];

  Map<String, dynamic>? questionnaireResultForInfant(String infantId) =>
      _questionnaireResults[infantId];

  int infantCountForVillage(String village) =>
      (_villageInfants[village] ?? []).length;

  // ── Actions ────────────────────────────────────────────────────────────────
  
  void _setStatus(AshaStatus status, {String? error}) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> login({required String ashaId, required String pin}) async {
    _setStatus(AshaStatus.loading);
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final worker = _registeredAshaWorkers.firstWhere(
        (w) => w.ashaId.toLowerCase() == ashaId.toLowerCase() && w.pin == pin
      );
      _asha = worker;
      _setStatus(AshaStatus.success);
      return true;
    } catch (e) {
      _setStatus(AshaStatus.error, error: 'Invalid ASHA ID or PIN');
      return false;
    }
  }

  void logout() {
    _asha = null;
    _status = AshaStatus.idle;
    notifyListeners();
  }

  Future<void> registerInfants({
    required String village,
    required List<Map<String, dynamic>> infants,
  }) async {
    _setStatus(AshaStatus.loading);
    await Future.delayed(const Duration(milliseconds: 600));
    final existing = _villageInfants[village] ?? [];
    _villageInfants[village] = [...existing, ...infants];
    _setStatus(AshaStatus.success);
  }

  Future<void> saveBoaResult(BoaResultModel result) async {
    _setStatus(AshaStatus.loading);
    await Future.delayed(const Duration(milliseconds: 600));
    _boaResults[result.infantId] = result;
    
    // Update infant status
    for (var village in _villageInfants.keys) {
      final list = _villageInfants[village]!;
      for (var i = 0; i < list.length; i++) {
        if (list[i]['id'] == result.infantId) {
          list[i]['status'] = 'Completed';
        }
      }
    }
    
    _setStatus(AshaStatus.success);
  }

  Future<void> saveQuestionnaireResult({
    required String infantId,
    required Map<String, dynamic> result,
  }) async {
    _setStatus(AshaStatus.loading);
    await Future.delayed(const Duration(milliseconds: 600));

    _questionnaireResults[infantId] = {
      ...result,
      'filledBy': 'asha',
      'ashaId': _asha?.ashaId,
      'savedAt': DateTime.now().toIso8601String(),
    };

    _setStatus(AshaStatus.success);
  }
}
