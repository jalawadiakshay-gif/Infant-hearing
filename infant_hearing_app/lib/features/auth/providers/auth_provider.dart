import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/models/v2/app_user.dart';
import '../../../data/services/v2/app_firestore_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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

  /// Helper to check if a user who just authenticated in Firebase Auth actually has an account registered in Firestore.
  /// If not found, automatically create an initial parent profile so registration and login are seamless.
  Future<bool> _checkUserRegistered(String identifier) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    _currentUserProfile = await firestoreService.getCurrentUser();
    if (_currentUserProfile == null) {
      // User is NOT registered in Firestore yet! Auto-create initial profile for seamless login/registration.
      final newUser = AppUser(
        uid: user.uid,
        name: user.displayName ?? (user.email != null ? user.email!.split('@').first : 'Parent / Caregiver'),
        phone: user.phoneNumber ?? (identifier.contains('@') ? '' : identifier),
        role: 'parent',
      );
      try {
        await firestoreService.saveUser(newUser);
        _currentUserProfile = newUser;
      } catch (e) {
        _setStatus(AuthStatus.error, error: 'Failed to create user profile: ${e.toString()}');
        return false;
      }
    }
    _setStatus(AuthStatus.success);
    return true;
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
          await _checkUserRegistered(formattedPhone);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setStatus(AuthStatus.error, error: _formatAuthError(e));
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
      _setStatus(AuthStatus.error, error: _formatAuthError(e));
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) {
      _setStatus(AuthStatus.error, error: "Verification ID missing. Please send OTP again.");
      return false;
    }

    _setStatus(AuthStatus.loading);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      final registered = await _checkUserRegistered(_phoneNumber ?? 'Phone');
      return registered;
    } catch (e) {
      _setStatus(AuthStatus.error, error: _formatAuthError(e));
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
      final registered = await _checkUserRegistered(email);
      return registered;
    } catch (e) {
      _setStatus(AuthStatus.error, error: _formatAuthError(e));
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
        _currentUserProfile = newUser;
      }
      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, error: _formatAuthError(e));
      return false;
    }
  }

  Future<bool> registerWithGoogle({required String phone}) async {
    _setStatus(AuthStatus.loading);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setStatus(AuthStatus.idle);
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      if (cred.user != null) {
        final newUser = AppUser(
          uid: cred.user!.uid,
          name: googleUser.displayName ?? googleUser.email.split('@').first,
          phone: phone,
          role: 'parent',
        );
        await firestoreService.saveUser(newUser);
        _currentUserProfile = newUser;
      }
      _setStatus(AuthStatus.success);
      return true;
    } catch (e) {
      _setStatus(AuthStatus.error, error: _formatAuthError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setStatus(AuthStatus.idle);
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      final registered = await _checkUserRegistered(googleUser.email);
      return registered;
    } catch (e) {
      _setStatus(AuthStatus.error, error: _formatAuthError(e));
      return false;
    }
  }

  String _formatAuthError(Object e) {
    final str = e.toString();
    if (str.contains('10:') || str.contains('sign_in_failed') || str.contains('12500') || str.contains('DEVELOPER_ERROR')) {
      return 'Google Sign-In failed (Error 10: Please add your debug/release APK SHA-1 fingerprint in the Firebase Console under Project Settings -> Android).';
    }
    if (str.contains('invalid-credential') || str.contains('user-not-found') || str.contains('wrong-password')) {
      return 'Invalid email or password. If you registered with Google, please click "Sign In with Google".';
    }
    if (str.contains('email-already-in-use')) {
      return 'This email address is already registered. Please sign in instead.';
    }
    if (str.contains('network-request-failed')) {
      return 'Network connection error. Please check your internet connection.';
    }
    if (str.contains('invalid-verification-code') || str.contains('session-expired')) {
      return 'Invalid or expired OTP verification code. Please request a new code.';
    }
    return str.replaceAll('Exception: ', '').replaceAll('PlatformException(', '').replaceAll('[]', '').trim();
  }
}