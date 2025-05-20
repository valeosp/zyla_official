// lib/screens/profile/qr_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user!.uid;

    // Colores de la aplicación - Paleta de tonos pasteles (coincide con profile_screen)
    final Color primaryColor = const Color(0xFFFFC2C7); // Rosa pastel
    final Color secondaryColor = const Color(0xFFFFE5E5); // Rosa claro
    final Color backgroundColor = const Color(0xFFFAFAFA); // Casi blanco
    final Color textColor = const Color(0xFF4A4A4A); // Gris oscuro para texto

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Código QR de pareja'),
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: textColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Texto explicativo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Comparte este código con tu pareja para vincular sus cuentas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ),

            const Spacer(),

            // QR Code con diseño mejorado
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contenedor decorativo para el QR
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: secondaryColor, width: 3),
                    ),
                    child: QrImageView(
                      data: uid,
                      version: QrVersions.auto,
                      size: 220,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: primaryColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: textColor,
                      ),
                      embeddedImage: const AssetImage(
                        'assets/logos/zyla_icon_small.png',
                      ),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: const Size(40, 40),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ID corto (opcional, primeros 8 caracteres del UID)
                  Text(
                    'ID: ${uid.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.7),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Instrucciones o botón de compartir
            Container(
              margin: const EdgeInsets.all(30),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Aquí podrías implementar la funcionalidad para compartir
                  // Por ejemplo, share_plus package
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Función de compartir próximamente'),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.share),
                label: const Text('Compartir código'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            // Nota informativa sobre privacidad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Text(
                'Este código es único para tu cuenta y solo debe compartirse con tu pareja',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
