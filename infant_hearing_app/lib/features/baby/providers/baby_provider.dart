import 'package:flutter/material.dart';
import '../models/baby_model.dart';
import '../../../shared/repositories/baby_repository.dart';

class BabyProvider extends ChangeNotifier {
  final BabyRepository babyRepository;

  List<BabyModel> _children = [];
  int _selectedBabyIndex = 0;
  bool _isSaving = false;

  BabyProvider({required this.babyRepository});

  List<BabyModel> get babies => _children;
  BabyModel? get baby =>
      _children.isNotEmpty ? _children[_selectedBabyIndex] : null;
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

  Future<void> fetchBabies() async {
    _errorMessage = null;
    try {
      _children = await babyRepository.getBabies();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> saveBaby({
    required String name,
    required DateTime dob,
    required String gender,
    required double birthWeight,
    required int gestationalAge,
    required bool nicuAdmission,
    required String deliveryMode,
    String? medicalNotes,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final newBaby = BabyModel(
      name: name,
      dob: dob,
      gender: gender,
      birthWeight: birthWeight,
      gestationalAge: gestationalAge,
      nicuAdmission: nicuAdmission,
      deliveryMode: deliveryMode,
      medicalNotes: medicalNotes,
    );

    try {
      final savedBaby = await babyRepository.createBaby(newBaby);
      _children.add(savedBaby);
      _selectedBabyIndex = _children.length - 1;
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