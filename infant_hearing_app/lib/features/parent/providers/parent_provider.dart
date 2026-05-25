import 'package:flutter/material.dart';
import '../models/parent_model.dart';
import '../../../shared/repositories/parent_repository.dart';

class ParentProvider extends ChangeNotifier {
  final ParentRepository parentRepository;

  ParentModel? _parent;
  bool _isSaving = false;
  bool _hasDeclared = false;

  ParentProvider({required this.parentRepository});

  ParentModel? get parent => _parent;
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
      _parent = await parentRepository.getParent();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> saveParent(ParentModel parent) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _parent = await parentRepository.createParent(parent);
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