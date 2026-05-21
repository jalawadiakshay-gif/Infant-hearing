import 'package:flutter/material.dart';
import '../models/asha_model.dart';
import '../models/boa_result_model.dart';

enum AshaStatus { idle, loading, success, error }

class AshaProvider extends ChangeNotifier {
  AshaModel? _asha;
  AshaStatus _status = AshaStatus.idle;
  String? _errorMessage;

  // In-memory store (Phase 1 — no backend, mirrors auth_provider.dart pattern)
  final List<AshaModel> _registeredAshaWorkers = [
    // Seeded demo worker so the app is usable immediately
    AshaModel(
      ashaId: 'ASHA001',
      name: 'Sunita Devi',
      pin: '1234',
      phoneNumber: '9876543210',
      assignedVillages: ['Rampur', 'Sitapur', 'Laxmipur'],
      assignedInfantIds: [],
    ),
  ];

  // Infants registered by this ASHA, keyed by village
  final Map<String, List<Map<String, dynamic>>> _villageInfants = {};

  // BOA results stored by infantId
  final Map<String, BoaResultModel> _boaResults = {};

  // Questionnaire results stored by infantId
  final Map<String, Map<String, dynamic>> _questionnaireResults = {};

  // ── Getters ────────────────────────────────────────────────────────────────
  AshaModel? get asha => _asha;
  AshaStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _asha != null;

  List<String> get assignedVillages => _asha?.assignedVillages ?? [];

  List<Map<String, dynamic>> infantsForVillage(String village) =>
      _villageInfants[village] ?? [];

  BoaResultModel? boaResultForInfant(String infantId) =>
      _boaResults[infantId];

  Map<String, dynamic>? questionnaireResultForInfant(String infantId) =>
      _questionnaireResults[infantId];

  int infantCountForVillage(String village) =>
      (_villageInfants[village] ?? []).length;

  // ── Status helpers ─────────────────────────────────────────────────────────
  void _setStatus(AshaStatus status, {String? error}) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<bool> login({
    required String ashaId,
    required String pin,
  }) async {
    _setStatus(AshaStatus.loading);

    await Future.delayed(const Duration(milliseconds: 1000));

    final worker = _registeredAshaWorkers.firstWhere(
      (w) =>
          w.ashaId.toLowerCase() == ashaId.toLowerCase() && w.pin == pin,
      orElse: () => AshaModel(
        ashaId: '',
        name: '',
        pin: '',
        phoneNumber: '',
        assignedVillages: [],
        assignedInfantIds: [],
      ),
    );

    if (worker.ashaId.isEmpty) {
      _setStatus(AshaStatus.error,
          error: 'Invalid ASHA ID or PIN. Please try again.');
      return false;
    }

    _asha = worker;
    _setStatus(AshaStatus.success);
    return true;
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  void logout() {
    _asha = null;
    _status = AshaStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _status = AshaStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Batch infant registration ──────────────────────────────────────────────
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

  // ── Save BOA result ────────────────────────────────────────────────────────
  Future<void> saveBoaResult(BoaResultModel result) async {
    _setStatus(AshaStatus.loading);

    await Future.delayed(const Duration(milliseconds: 600));

    _boaResults[result.infantId] = result;

    _setStatus(AshaStatus.success);
  }

  // ── Save questionnaire result (filled by ASHA on behalf of infant) ─────────
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