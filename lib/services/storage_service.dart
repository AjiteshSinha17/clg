import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // -------- Image uploads (cross-platform: Web + Mobile) --------

  Future<String> uploadProfileImageXFile(String userId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      final bytes = await imageFile.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<String> uploadCollegeIdXFile(String userId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('college_ids/$userId.jpg');
      final bytes = await imageFile.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload college ID: $e');
    }
  }

  Future<String> uploadBannerImageXFile(String userId, XFile imageFile) async {
    try {
      final ref = _storage.ref().child('profile_banners/$userId.jpg');
      final bytes = await imageFile.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload banner image: $e');
    }
  }

  /// Upload a PDF file for community content
  Future<String> uploadPDFBytes(String userId, Uint8List bytes, {String? fileName}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'document_$timestamp.pdf';
      final ref = _storage.ref().child('community_content/pdfs/$userId/$name');
      await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }

  /// Upload an image file for community content
  Future<String> uploadCommunityImageBytes(String userId, Uint8List bytes, {String? fileName}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName?.split('.').last ?? 'jpg';
      final name = fileName ?? 'image_$timestamp.$extension';
      final ref = _storage.ref().child('community_content/images/$userId/$name');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/$extension'));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload community image: $e');
    }
  }

  /// Upload any file type for community content (notes, documents, etc.)
  Future<String> uploadCommunityFileBytes(String userId, Uint8List bytes, {String? fileName, String? contentType}) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName?.split('.').last ?? 'file';
      final name = fileName ?? 'file_$timestamp.$extension';
      final ref = _storage.ref().child('community_content/files/$userId/$name');
      await ref.putData(bytes, SettableMetadata(contentType: contentType));
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload multiple files at once
  Future<List<String>> uploadMultipleFileBytes(String userId, List<Uint8List> filesBytes) async {
    try {
      final List<String> urls = [];
      for (var bytes in filesBytes) {
        final url = await uploadCommunityFileBytes(userId, bytes);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  /// Delete a file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
