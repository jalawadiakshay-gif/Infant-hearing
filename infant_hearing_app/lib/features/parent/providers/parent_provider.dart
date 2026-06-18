import 'package:flutter/material.dart';
import '../../../data/models/v2/app_user.dart';
import '../../../data/services/v2/app_firestore_service.dart';

class ParentProvider extends ChangeNotifier {
  final AppFirestoreService firestoreService;

  AppUser? _parent;
  bool _isSaving = false;
  bool _hasDeclared = false;

  ParentProvider({required this.firestoreService});

  AppUser? get parent => _parent;
  bool get isSaving => _isSaving;
  bool get hasParentData => _parent != null;
  bool get hasDeclared => _hasDeclared;

  void setDeclaration(bool value) {
    _hasDeclared = value;
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchParent() async {
    _errorMessage = null;
    try {
      _parent = await firestoreService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> saveParent(AppUser parent) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await firestoreService.saveUser(parent);
      _parent = parent;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> clearParent() async {
    _parent = null;
    _hasDeclared = false;
    notifyListeners();
  }
}