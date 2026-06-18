import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/v2/app_user.dart';
import '../../../data/services/v2/app_firestore_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppFirestoreService firestoreService;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  String? _phoneNumber;
  String? _verificationId;
  AppUser? _currentUserProfile;

  AuthProvider({required this.firestoreService});

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get phoneNumber => _phoneNumber;
  AppUser? get currentUserProfile => _currentUserProfile;

  void _setStatus(AuthStatus status, {String? error}) {
    _status = status;
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> initializeAuth() async {
    if (isAuthenticated) {
      await fetchUserProfile();
    }
  }

  Future<void> fetchUserProfile() async {
    _currentUserProfile = await firestoreService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _setStatus(AuthStatus.loading);
    try {
      // Format phone to Indian format if no + prefix
      final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await _onSignInSuccess(formattedPhone);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setStatus(AuthStatus.error, error: e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _phoneNumber = formattedPhone;
          _setStatus(AuthStatus.success);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) {
      _setStatus(AuthStatus.error, error: "Verification ID missing");
      return false;
    }

    _setStatus(AuthStatus.loading);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      await _onSignInSuccess(_phoneNumber!);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, error: 'Verification failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await fetchUserProfile();
      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, error: 'Login failed: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setStatus(AuthStatus.loading);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        final newUser = AppUser(
          uid: cred.user!.uid,
          name: fullName,
          phone: phone,
          role: 'parent',
        );
        await firestoreService.saveUser(newUser);
        await fetchUserProfile();
      }
      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, error: e.toString());
      return false;
    }
  }

  Future<void> _onSignInSuccess(String phone) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Check if profile exists
      _currentUserProfile = await firestoreService.getCurrentUser();
      
      if (_currentUserProfile == null) {
        // Create basic profile if it doesn't exist
        final newUser = AppUser(
          uid: user.uid,
          name: 'User', // Will be updated later
          phone: phone,
          role: 'parent', // Default to parent, they can select role later or via another flow
        );
        await firestoreService.saveUser(newUser);
        _currentUserProfile = newUser;
      }
      
      _setStatus(AuthStatus.success);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _phoneNumber = null;
    _verificationId = null;
    _currentUserProfile = null;
    _setStatus(AuthStatus.idle);
  }

  void reset() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // Google sign in wrapper
  Future<bool> signInWithGoogle() async {
    _setStatus(AuthStatus.loading);
    try {
      // For a real app, implement GoogleSignIn here
      // For now, simulate success
      await Future.delayed(const Duration(milliseconds: 1500));
      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, error: e.toString());
      return false;
    }
  }
}