import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadUserImage(File file) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final name = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref('user_uploads/$uid/$name.jpg');

    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}