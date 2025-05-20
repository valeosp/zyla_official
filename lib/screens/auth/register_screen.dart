import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _conf = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _conf.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.status == Status.emailUnverified) {
        Navigator.pushReplacementNamed(context, '/verify-email');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _conf,
                decoration: const InputDecoration(labelText: 'Confirmar'),
                obscureText: true,
                validator: (v) => v == _pass.text ? null : 'No coinciden',
              ),
              const SizedBox(height: 24),
              if (auth.errorMessage != null)
                Text(
                  auth.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed:
                    auth.status == Status.authenticating
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            auth.registerWithEmail(
                              _email.text.trim(),
                              _pass.text.trim(),
                            );
                          }
                        },
                child:
                    auth.status == Status.authenticating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Crear cuenta'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
