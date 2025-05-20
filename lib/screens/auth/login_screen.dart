import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Reacción a cambios de estado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.status == Status.authenticated) {
        Navigator.pushReplacementNamed(context, '/');
      } else if (auth.status == Status.emailUnverified) {
        Navigator.pushReplacementNamed(context, '/verify-email');
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bienvenida a ZYLA', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator:
                    (v) =>
                        v != null && v.contains('@') ? null : 'Correo inválido',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pass,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator:
                    (v) => v != null && v.length >= 6 ? null : '6+ caracteres',
              ),
              const SizedBox(height: 24),
              if (auth.errorMessage != null)
                Text(
                  auth.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed:
                    auth.status == Status.authenticating
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            auth.loginWithEmail(
                              _email.text.trim(),
                              _pass.text.trim(),
                            );
                          }
                        },
                child:
                    auth.status == Status.authenticating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
