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

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _canResend = true;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    // Cada 5s recarga usuario
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      Provider.of<AuthProvider>(context, listen: false).reloadUser();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // Si ya verificó, navegamos
    if (auth.status == Status.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      });
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_read, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                'Verifica tu correo:\n${auth.user?.email ?? ''}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _canResend ? _onResend : null,
                child: Text(
                  _canResend
                      ? 'Reenviar verificación'
                      : 'Reenviar en $_resendCountdown s',
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  auth.signOut();
                  Navigator.pushReplacementNamed(context, '/welcome');
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
