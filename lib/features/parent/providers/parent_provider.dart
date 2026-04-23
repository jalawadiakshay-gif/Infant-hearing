import 'package:flutter/material.dart';
import '../models/parent_model.dart';

class ParentProvider extends ChangeNotifier {
  ParentModel? _parent;
  bool _isSaving = false;

  ParentModel? get parent => _parent;
  bool get isSaving => _isSaving;
  bool get hasParentData => _parent != null;

  Future<void> saveParent({
    required String name,
    required int age,
    required String gender,
    required String contactNumber,
    required String address,
  }) async {
    _isSaving = true;
    notifyListeners();

    // Simulate save delay (replace with actual persistence later)
    await Future.delayed(const Duration(milliseconds: 600));

    _parent = ParentModel(
      name: name,
      age: age,
      gender: gender,
      contactNumber: contactNumber,
      address: address,
    );

    _isSaving = false;
    notifyListeners();
  }

  void clearParent() {
    _parent = null;
    notifyListeners();
  }
}
