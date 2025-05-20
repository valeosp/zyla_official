// lib/screens/profile/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zyla/services/firestore_service.dart';
import 'package:zyla/services/storage_service.dart';
import 'package:zyla/providers/auth_provider.dart';
import 'package:zyla/screens/profile/qr_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _photoUrl;
  final _firestore = FirestoreService();
  final _storage = StorageService();

  // Colores de la aplicación - Paleta de tonos pasteles
  final Color _primaryColor = const Color(0xFFFFC2C7); // Rosa pastel
  final Color _secondaryColor = const Color(0xFFFFE5E5); // Rosa claro
  final Color _accentColor = const Color(0xFFF8BBD0); // Rosa pálido
  final Color _backgroundColor = const Color(0xFFFAFAFA); // Casi blanco
  final Color _textColor = const Color(0xFF4A4A4A); // Gris oscuro para texto

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
    // Diálogo personalizado y estilizado para cambiar foto
    showDialog(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título con icono decorativo
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.camera_fill,
                      color: _primaryColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Actualizar Foto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '¿Cómo te gustaría cambiar tu foto?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Opciones con iconos atractivos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Opción Galería
                      _buildPhotoOption(
                        icon: CupertinoIcons.photo_on_rectangle,
                        title: 'Galería',
                        color: const Color(0xFFE0F7FA),
                        iconColor: Colors.cyan,
                        onTap: () async {
                          Navigator.pop(context);
                          await _pickImage(ImageSource.gallery);
                        },
                      ),

                      // Opción Cámara
                      _buildPhotoOption(
                        icon: CupertinoIcons.camera_viewfinder,
                        title: 'Cámara',
                        color: const Color(0xFFE8F5E9),
                        iconColor: Colors.green,
                        onTap: () async {
                          Navigator.pop(context);
                          await _pickImage(ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Botón Cancelar
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: _textColor.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Widget para las opciones de foto
  Widget _buildPhotoOption({
    required IconData icon,
    required String title,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: _textColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
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
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Cambiar contraseña',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: currentCtrl,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _secondaryColor.withOpacity(0.5),
                      prefixIcon: const Icon(CupertinoIcons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _secondaryColor.withOpacity(0.5),
                      prefixIcon: const Icon(CupertinoIcons.lock_rotation),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: _textColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await context.read<AuthProvider>().changePassword(
                              currentCtrl.text.trim(),
                              newCtrl.text.trim(),
                            );
                            Navigator.pop(context);

                            // Feedback estilo iOS
                            showCupertinoDialog(
                              context: context,
                              builder:
                                  (context) => CupertinoAlertDialog(
                                    title: const Text('Éxito'),
                                    content: const Text(
                                      'Tu contraseña ha sido actualizada correctamente.',
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text('Aceptar'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                            );
                          } catch (e) {
                            Navigator.pop(context);
                            showCupertinoDialog(
                              context: context,
                              builder:
                                  (context) => CupertinoAlertDialog(
                                    title: const Text('Error'),
                                    content: Text(
                                      'No se pudo actualizar la contraseña: $e',
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text('Aceptar'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor ?? _secondaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor ?? _secondaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor ?? _textColor),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: _textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.chevron_right,
                color: _textColor.withOpacity(0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _textColor,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar y correo
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Avatar con borde suave
                    GestureDetector(
                      onTap: _changePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _primaryColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: size.width * 0.15, // Ligeramente más pequeño
                          backgroundColor: _secondaryColor,
                          backgroundImage:
                              _photoUrl != null
                                  ? NetworkImage(_photoUrl!)
                                  : null,
                          child:
                              _photoUrl == null
                                  ? Icon(
                                    CupertinoIcons.person_fill,
                                    size: size.width * 0.12,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Icono de editar
                    GestureDetector(
                      onTap: _changePhoto,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.camera,
                              size: 16,
                              color: _primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Cambiar foto',
                              style: TextStyle(
                                fontSize: 14,
                                color: _primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email con icono
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: _secondaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.mail,
                            color: _primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.email ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: _textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Título de sección
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 16),
                  child: Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                ),
              ),

              // Opciones de perfil
              _buildProfileOption(
                icon: CupertinoIcons.lock_shield,
                title: 'Cambiar contraseña',
                onTap: _changePassword,
                backgroundColor: _accentColor.withOpacity(0.3),
                iconColor: _primaryColor,
              ),

              _buildProfileOption(
                icon: CupertinoIcons.qrcode,
                title: 'Código QR de pareja',
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrScreen()),
                    ),
                backgroundColor: _accentColor.withOpacity(0.3),
                iconColor: _primaryColor,
              ),

              const SizedBox(height: 16),

              // Título de sección
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 16),
                  child: Text(
                    'Cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                ),
              ),

              // Cerrar sesión

              // Reemplaza el diálogo de cierre de sesión actual con este diseño personalizado
              _buildProfileOption(
                icon: CupertinoIcons.square_arrow_left,
                title: 'Cerrar sesión',
                onTap: () {
                  // Mostrar diálogo personalizado con tonos pastel rosa y azul
                  showDialog(
                    context: context,
                    builder:
                        (context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFFF0F5), // Rosa muy pálido
                                  const Color(0xFFE6F0FF), // Azul muy pálido
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icono decorativo en un círculo
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFFFC2C7), // Rosa pastel
                                        const Color(0xFFB5E8FF), // Azul pastel
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.square_arrow_left,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Título con estilo
                                Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: _textColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Mensaje
                                Text(
                                  '¿Estás segura de que deseas cerrar sesión?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _textColor.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Botones con estilo personalizado
                                Row(
                                  children: [
                                    // Botón Cancelar
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            side: BorderSide(
                                              color: _primaryColor.withOpacity(
                                                0.5,
                                              ),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            color: _textColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Botón Cerrar Sesión
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await auth.signOut();
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            '/welcome',
                                            (route) => false,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          backgroundColor: const Color(
                                            0xFFFFC2C7,
                                          ), // Rosa pastel
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cerrar sesión',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                },
                backgroundColor: const Color(0xFFFFDEDE),
                iconColor: Colors.redAccent,
              ),

              // Nueva funcionalidad: Recordatorios del ciclo
              _buildProfileOption(
                icon: CupertinoIcons.bell,
                title: 'Recordatorios del ciclo',
                onTap: () {
                  showCupertinoDialog(
                    context: context,
                    builder:
                        (context) => CupertinoAlertDialog(
                          title: const Text('Próximamente'),
                          content: const Text(
                            'Los recordatorios personalizados estarán disponibles en la próxima actualización.',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('Aceptar'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                  );
                },
                backgroundColor: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
