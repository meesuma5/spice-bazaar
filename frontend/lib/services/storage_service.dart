import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file
  Future<String> uploadFile(String path, File file) async {
    try {
      TaskSnapshot snapshot = await _storage.ref(path).putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file: $e');
      throw e;
    }
  }

  // Get a download URL
  Future<String> getDownloadURL(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      throw e;
    }
  }

  // Delete a file
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      print('Error deleting file: $e');
      throw e;
    }
  }
}
