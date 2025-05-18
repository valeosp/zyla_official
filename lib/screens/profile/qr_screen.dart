// lib/screens/profile/qr_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Código QR')),
      body: Center(
        child: QrImageView(
          // ← aquí cambió de QrImage a QrImageView
          data: uid,
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
