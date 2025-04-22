import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file
  Future<String> uploadFile(String path, File file) async {
    TaskSnapshot? snapshot;
		try {

			final fileName = file.path.split('/').last;
			print(fileName);
			snapshot = await _storage.ref(fileName).putFile(file);
			print("File uploaded successfully");
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
			if (e is FirebaseException) {
				if (snapshot != null) {
					print('Firebase Storage Error: [${snapshot.state}] ${snapshot.ref} ${snapshot.metadata}');
					print(snapshot.ref);
				}
				print('Firebase Storage Error: [${e.code}] ${e.message}');
			} else {
				print('Error uploading file: $e');
			}
      print('Error uploading file: $e');
      rethrow;
    }
  }

  // Get a download URL
  Future<String> getDownloadURL(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }

  // Delete a file
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
}
