import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // Si ya autenticó, redirige
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.status == Status.authenticated) {
        Navigator.pushReplacementNamed(context, '/');
      } else if (auth.status == Status.emailUnverified) {
        Navigator.pushReplacementNamed(context, '/verify-email');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // tu diseño gradient + blur...
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo y título...
                ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                  child: const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
