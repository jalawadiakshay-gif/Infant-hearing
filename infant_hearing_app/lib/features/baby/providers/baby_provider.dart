import 'package:flutter/material.dart';
import '../../../data/models/v2/child.dart';
import '../../../data/services/v2/app_firestore_service.dart';

class BabyProvider extends ChangeNotifier {
  final AppFirestoreService firestoreService;

  List<Child> _children = [];
  int _selectedBabyIndex = 0;
  bool _isSaving = false;

  BabyProvider({required this.firestoreService});

  List<Child> get babies => _children;
  Child? get baby =>
      _children.isNotEmpty && _selectedBabyIndex < _children.length
          ? _children[_selectedBabyIndex]
          : null;
  bool get isSaving => _isSaving;
  bool get hasBabyData => _children.isNotEmpty;
  bool get hasChildren => _children.isNotEmpty;

  void selectBaby(int index) {
    if (index >= 0 && index < _children.length) {
      _selectedBabyIndex = index;
      notifyListeners();
    }
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Stream subscription for children
  void startListeningToChildren(String userUid) {
    _errorMessage = null;
    firestoreService.getChildrenForAsha(userUid).listen(
      (children) {
        _children = children;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> saveBaby({
    required String name,
    required DateTime dob,
    required String gender,
    required String parentName,
    required String parentPhone,
    required String createdBy,
    required bool nicuAdmission,
    double? birthWeight,
    int? gestationalAge,
    String? birthType,
    int? nicuDuration,
    String? hospitalName,
    String? pediatricianName,
    String? hearingScreeningStatus,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final newChild = Child(
      childId: '',
      name: name,
      dob: dob,
      gender: gender,
      parentName: parentName,
      parentPhone: parentPhone,
      createdBy: createdBy,
      riskNicu: nicuAdmission,
      birthWeight: birthWeight,
      gestationalAge: gestationalAge,
      birthType: birthType,
      nicuDuration: nicuDuration,
      hospitalName: hospitalName,
      pediatricianName: pediatricianName,
      hearingScreeningStatus: hearingScreeningStatus,
    );

    try {
      final childId = await firestoreService.registerChild(newChild);
      // Optimistically add to list so router's hasChildren check passes immediately
      _children.add(newChild.copyWith(childId: childId));
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> clearBaby() async {
    _children = [];
    _selectedBabyIndex = 0;
    notifyListeners();
  }
}