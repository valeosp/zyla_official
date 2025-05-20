import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum Status {
  uninitialized,
  authenticating,
  authenticated,
  unauthenticated,
  emailUnverified, // Nuevo estado para usuarios pendientes de verificar
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Status _status = Status.uninitialized;
  User? _user;
  String? errorMessage;

  AuthProvider() {
    // Escucha cambios de autenticación
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Status get status => _status;
  User? get user => _user;

  /// Registro + envío de verificación
  Future<void> registerWithEmail(String email, String password) async {
    _status = Status.authenticating;
    errorMessage = null;
    notifyListeners();
    try {
      final newUser = await _authService.signUp(email, password);
      _user = newUser;
      // Marcamos como pendiente de verificación
      _status = Status.emailUnverified;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      _status = Status.unauthenticated;
    }
    notifyListeners();
  }

  /// Login + chequeo de emailVerified
  Future<void> loginWithEmail(String email, String password) async {
    _status = Status.authenticating;
    errorMessage = null;
    notifyListeners();
    try {
      final loggedUser = await _authService.signIn(email, password);
      _user = loggedUser;
      if (_user != null && _user!.emailVerified) {
        _status = Status.authenticated;
      } else {
        // reenviamos verificación si no está verificado
        await _authService.sendEmailVerification();
        _status = Status.emailUnverified;
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      _status = Status.unauthenticated;
    }
    notifyListeners();
  }

  /// Reenvía el correo de verificación
  Future<void> sendEmailVerification() async {
    if (_user != null && !_user!.emailVerified) {
      await _authService.sendEmailVerification();
    }
  }

  /// Fuerza recarga del usuario para detectar verificación
  Future<void> reloadUser() async {
    if (_user == null) return;
    await _authService.currentUser!.reload();
    final refreshed = _authService.currentUser;
    if (refreshed != null && refreshed.emailVerified) {
      _user = refreshed;
      _status = Status.authenticated;
      notifyListeners();
    }
  }

  /// Cambio de contraseña tras reautenticación en AuthService
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _status = Status.authenticating;
    notifyListeners();
    try {
      await _authService.changePassword(currentPassword, newPassword);
      _status = Status.authenticated;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      _status = Status.authenticated;
    } catch (e) {
      errorMessage = e.toString();
      _status = Status.authenticated;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = Status.unauthenticated;
    notifyListeners();
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.unauthenticated;
    } else if (!firebaseUser.emailVerified) {
      _user = firebaseUser;
      _status = Status.emailUnverified;
    } else {
      _user = firebaseUser;
      _status = Status.authenticated;
    }
    notifyListeners();
  }
}
