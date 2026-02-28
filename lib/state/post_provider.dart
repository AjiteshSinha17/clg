
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/storage_service.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService = StorageService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> createPost(
      {required String title, required String content, XFile? image}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final uid = _auth.currentUser!.uid;
      String? imageUrl;

      if (image != null) {
        final bytes = await image.readAsBytes();
        imageUrl = await _storageService.uploadCommunityImageBytes(
          uid,
          bytes,
          fileName: image.name,
        );
      }

      await _firestore.collection('posts').add({
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'authorId': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
