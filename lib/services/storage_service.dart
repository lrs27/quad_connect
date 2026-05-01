import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);

    final metadata = SettableMetadata(contentType: "image/png");

    await ref.putFile(file, metadata);

    return await ref.getDownloadURL();
  }
}
