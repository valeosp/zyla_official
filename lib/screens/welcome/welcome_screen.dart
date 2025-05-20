// lib/screens/welcome/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zyla/screens/auth/login_screen.dart';
import 'package:zyla/screens/auth/register_screen.dart';
import 'package:zyla/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// Clase para los elementos decorativos
enum DecorationItemType { heart, flower, star }

class DecorationItem {
  final DecorationItemType type;
  final double size;
  final double rotation;
  final Offset position;
  final double opacity;

  DecorationItem({
    required this.type,
    required this.size,
    required this.rotation,
    required this.position,
    required this.opacity,
  });
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  // Lista de elementos decorativos
  final List<DecorationItem> _decorations = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<double>(
      begin: 50,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    //  elementos decorativos
    _generateDecorations();

    _controller.forward();
  }

  void _generateDecorations() {
    // Crear 16 elementos decorativos aleatorios
    for (int i = 0; i < 16; i++) {
      final type =
          _random.nextBool()
              ? DecorationItemType.heart
              : (_random.nextDouble() > 0.5
                  ? DecorationItemType.flower
                  : DecorationItemType.star);

      final size = 10.0 + _random.nextDouble() * 15.0;
      final rotation = _random.nextDouble() * math.pi * 2;
      final xPosition = _random.nextDouble();
      final yPosition = _random.nextDouble();
      final opacity = 0.3 + _random.nextDouble() * 0.4;

      _decorations.add(
        DecorationItem(
          type: type,
          size: size,
          rotation: rotation,
          position: Offset(xPosition, yPosition),
          opacity: opacity,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.status == Status.authenticated) {
        Navigator.pushReplacementNamed(context, '/');
      } else if (auth.status == Status.emailUnverified) {
        Navigator.pushReplacementNamed(context, '/verify-email');
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFC6C3),
              const Color(0xFFFFC6C3),
              const Color(0xFFFFC6C3).withOpacity(0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Elementos decorativos en el fondo
            ..._decorations.map(
              (decoration) => Positioned(
                left: decoration.position.dx * size.width,
                top: decoration.position.dy * size.height,
                child: Opacity(
                  opacity: decoration.opacity,
                  child: Transform.rotate(
                    angle: decoration.rotation,
                    child: _buildDecorationWidget(decoration),
                  ),
                ),
              ),
            ),

            // Contenido principal
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 30),
                        // Illustration at the top
                        FadeTransition(
                          opacity: _fadeIn,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: Image.asset(
                              'assets/images/girl-power-reproductive-system-concept.png',
                              height: size.height * 0.38,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Welcome Text
                        FadeTransition(
                          opacity: _fadeIn,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: Text(
                              'Bienvenida a Zyla',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.pink.shade700.withOpacity(
                                      0.5,
                                    ),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Motivational Text
                        FadeTransition(
                          opacity: _fadeIn,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: Text(
                              'Conoce tu cuerpo, empodera tu ciclo y cuida tu salud con amor y atención',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1.4,
                                shadows: [
                                  Shadow(
                                    color: Colors.pink.shade700.withOpacity(
                                      0.3,
                                    ),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Ajustamos la distancia entre el texto y los botones
                        SizedBox(height: size.height * 0.15),

                        // Buttons side by side
                        FadeTransition(
                          opacity: _fadeIn,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: Row(
                              children: [
                                // Register Button (Left)
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color.fromARGB(
                                        255,
                                        255,
                                        107,
                                        129,
                                      ),
                                      side: const BorderSide(
                                        color: Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      textStyle: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text('Registrarse'),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Login Button (Right)
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFFFF6B81),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      elevation: 2,
                                      shadowColor: Colors.white.withOpacity(
                                        0.4,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      textStyle: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text('Iniciar Sesión'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorationWidget(DecorationItem decoration) {
    switch (decoration.type) {
      case DecorationItemType.heart:
        return Icon(
          Icons.favorite,
          size: decoration.size,
          color: Colors.white.withOpacity(decoration.opacity),
        );
      case DecorationItemType.flower:
        return Icon(
          Icons.spa,
          size: decoration.size,
          color: Colors.white.withOpacity(decoration.opacity),
        );
      case DecorationItemType.star:
        return Icon(
          Icons.star,
          size: decoration.size,
          color: Colors.white.withOpacity(decoration.opacity),
        );
    }
  }
}
