// lib/screens/profile/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zyla/services/firestore_service.dart';
import 'package:zyla/services/storage_service.dart';
import 'package:zyla/providers/auth_provider.dart';
import 'package:zyla/screens/profile/qr_screen.dart';
import 'package:zyla/screens/profile/partner_view_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _photoUrl;
  final _firestore = FirestoreService();
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = context.read<AuthProvider>().user!.uid;
    final data = await _firestore.getUserData(uid);
    setState(() {
      _photoUrl = data?['photoUrl'] as String?;
    });
  }

  Future<void> _changePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final uid = context.read<AuthProvider>().user!.uid;
    final url = await _storage.uploadProfileImage(uid, file);
    await _firestore.updateUserProfile(uid, {'photoUrl': url});
    setState(() => _photoUrl = url);
  }

  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Cambiar contraseña'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña actual',
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: newCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await context.read<AuthProvider>().changePassword(
                      currentCtrl.text.trim(),
                      newCtrl.text.trim(),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contraseña actualizada')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              GestureDetector(
                onTap: _changePhoto,
                child: CircleAvatar(
                  radius: size.width * 0.2, // 20% del ancho de pantalla
                  backgroundImage:
                      _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                  child:
                      _photoUrl == null
                          ? Icon(Icons.person, size: size.width * 0.2)
                          : null,
                ),
              ),
              const SizedBox(height: 16),

              // Email
              Text(
                user.email ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Cambiar contraseña
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Cambiar contraseña'),
                ),
              ),
              const SizedBox(height: 12),

              // Ver QR de pareja
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QrScreen()),
                      ),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Código QR de pareja'),
                ),
              ),
              const SizedBox(height: 12),

              // Ver datos de pareja (test)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    const testPartnerUid = 'AQUI_EL_UID';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) =>
                                PartnerViewScreen(partnerUid: testPartnerUid),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: const Text('Ver datos de pareja (test)'),
                ),
              ),
              const SizedBox(height: 24),

              // Cerrar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
