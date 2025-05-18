//lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registra un usuario y le envía correo de verificación
  Future<User?> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.sendEmailVerification();
    return credential.user;
  }

  // Inicia sesión con email/clave
  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // Cierra sesión
  Future<void> signOut() => _auth.signOut();

  // Reenvía correo de verificación
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Stream de cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  /// Cambia la contraseña del usuario actual
  /// Requiere la contraseña actual para reautenticación
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No hay usuario autenticado.',
      );
    }
    // Creamos credenciales para reautenticar
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    // Reautenticamos
    await user.reauthenticateWithCredential(cred);
    // Actualizamos la contraseña
    await user.updatePassword(newPassword);
    // Opcional: cerrar sesión en otros dispositivos
  }
}
