//lib/screens/auth/email_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _canResend = true;
  int _resendCountdown = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    // Cada 5s recarga usuario
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      Provider.of<AuthProvider>(context, listen: false).reloadUser();
    });

    // Configurar animación
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
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onResend() async {
    if (!_canResend) return;
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });
    Provider.of<AuthProvider>(context, listen: false).sendEmailVerification();
    // Cuenta regresiva
    Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          t.cancel();
        }
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Correo de verificación enviado'),
        backgroundColor: Color(0xFF66BB6A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    // Definición de colores
    const Color primaryColor = Color(0xFFFFC6C3);
    const Color secondaryColor = Color(0xFFFAE0DF);
    const Color accentColor = Color(0xFFFF9A94);

    // Si ya verificó, navegamos
    if (auth.status == Status.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      });
    }

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono de email verificado
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read,
                          size: 60,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Título
                      const Text(
                        '¡Ya casi estamos!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A4A4A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Información de verificación
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
                        child: Column(
                          children: [
                            // Texto explicativo
                            Text(
                              'Hemos enviado un correo de verificación a:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Correo del usuario
                            Text(
                              auth.user?.email ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Instrucciones adicionales
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Revisa tu bandeja de entrada y haz clic en el enlace de verificación para continuar.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botón reenviar verificación
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _canResend ? _onResend : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _canResend
                                    ? 'Reenviar verificación'
                                    : 'Reenviar en $_resendCountdown s',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botón de cerrar sesión
                      TextButton.icon(
                        onPressed: () {
                          auth.signOut();
                          Navigator.pushReplacementNamed(context, '/welcome');
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                    ],
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
