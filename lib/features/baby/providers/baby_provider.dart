import 'package:flutter/material.dart';
import '../models/baby_model.dart';

class BabyProvider extends ChangeNotifier {
  BabyModel? _baby;
  bool _isSaving = false;

  BabyModel? get baby => _baby;
  bool get isSaving => _isSaving;
  bool get hasBabyData => _baby != null;

  Future<void> saveBaby({
    required String name,
    required int ageMonths,
    required double birthWeight,
    required int gestationalAge,
    required bool nicuAdmission,
    required String deliveryMode,
  }) async {
    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _baby = BabyModel(
      name: name,
      ageMonths: ageMonths,
      birthWeight: birthWeight,
      gestationalAge: gestationalAge,
      nicuAdmission: nicuAdmission,
      deliveryMode: deliveryMode,
    );

    _isSaving = false;
    notifyListeners();
  }

  void clearBaby() {
    _baby = null;
    notifyListeners();
  }
}
