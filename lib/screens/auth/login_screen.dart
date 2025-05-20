// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    // Definición de colores
    const Color primaryColor = Color(0xFFFFC6C3);
    const Color secondaryColor = Color(0xFFFAE0DF);
    const Color accentColor = Color(0xFFFF9A94);

    // Reacción a cambios de estado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.status == Status.authenticated) {
        Navigator.pushReplacementNamed(context, '/');
      } else if (auth.status == Status.emailUnverified) {
        Navigator.pushReplacementNamed(context, '/verify-email');
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo con círculos decorativos
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor,
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.4,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: secondaryColor,
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo o ícono de la app
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: 60,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Título
                        const Text(
                          'Bienvenida a ZYLA',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A4A4A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtítulo
                        Text(
                          'Tu compañera de ciclo menstrual',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Formulario
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Campo de correo
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Correo electrónico',
                                    hintText: 'ejemplo@correo.com',
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: accentColor,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: accentColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  validator:
                                      (v) =>
                                          v != null && v.contains('@')
                                              ? null
                                              : 'Ingresa un correo válido',
                                ),
                                const SizedBox(height: 20),

                                // Campo de contraseña
                                TextFormField(
                                  controller: _pass,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    hintText: 'Mínimo 8 caracteres',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: accentColor,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: accentColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  validator:
                                      (v) =>
                                          v != null && v.length >= 6
                                              ? null
                                              : 'La contraseña debe tener al menos 8 caracteres',
                                ),

                                // Mensaje de error
                                if (auth.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              auth.errorMessage!,
                                              style: const TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 32),

                                // Botón de iniciar sesión
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                        auth.status == Status.authenticating
                                            ? null
                                            : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                auth.loginWithEmail(
                                                  _email.text.trim(),
                                                  _pass.text.trim(),
                                                );
                                              }
                                            },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      disabledBackgroundColor: primaryColor
                                          .withOpacity(0.7),
                                    ),
                                    child:
                                        auth.status == Status.authenticating
                                            ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.0,
                                              ),
                                            )
                                            : const Text(
                                              'Iniciar sesión',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Enlace para registrarse
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: TextButton(
                            onPressed:
                                () => Navigator.pushNamed(context, '/register'),
                            style: TextButton.styleFrom(
                              foregroundColor: accentColor,
                            ),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 15),
                                children: [
                                  TextSpan(
                                    text: '¿No tienes cuenta? ',
                                    style: TextStyle(color: Color(0xFF707070)),
                                  ),
                                  TextSpan(
                                    text: 'Regístrate',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
