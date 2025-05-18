import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sube imagen de perfil y retorna URL
  Future<String> uploadProfileImage(String uid, File file) async {
    final ref = _storage.ref().child('users/$uid/profile.jpg');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }
}
