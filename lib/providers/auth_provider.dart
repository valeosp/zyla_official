// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum Status { uninitialized, authenticating, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Status _status = Status.uninitialized;
  User? _user;
  String? errorMessage;

  AuthProvider() {
    // Escucha cambios en el estado de autenticación
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Status get status => _status;
  User? get user => _user;

  /// Registro con envío automático de correo de verificación
  Future<void> registerWithEmail(String email, String password) async {
    _status = Status.authenticating;
    notifyListeners();
    try {
      final newUser = await _authService.signUp(email, password);
      _user = newUser;
      // Enviar correo de verificación
      await _authService.sendEmailVerification();
      _status = Status.unauthenticated; // Hasta que confirme su correo
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      _status = Status.unauthenticated;
    }
    notifyListeners();
  }

  /// Login y validación de verificación de correo
  Future<void> loginWithEmail(String email, String password) async {
    _status = Status.authenticating;
    notifyListeners();
    try {
      final loggedUser = await _authService.signIn(email, password);
      if (loggedUser != null && loggedUser.emailVerified) {
        _user = loggedUser;
        _status = Status.authenticated;
      } else {
        errorMessage = 'Por favor, verifica tu correo electrónico.';
        _status = Status.unauthenticated;
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      _status = Status.unauthenticated;
    }
    notifyListeners();
  }

  /// Reenvío manual de correo de verificación
  Future<void> sendEmailVerification() async {
    if (_user != null && !_user!.emailVerified) {
      await _authService.sendEmailVerification();
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

  /// Cerrar sesión
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = Status.unauthenticated;
    notifyListeners();
  }

  /// Handler interno de cambios en el estado de FirebaseAuth
  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser == null || !firebaseUser.emailVerified) {
      _user = firebaseUser;
      _status = Status.unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.authenticated;
    }
    notifyListeners();
  }
}
