
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        final ref = _storage.ref().child('post_images').child('${DateTime.now()}.jpg');
        await ref.putFile(File(image.path));
        imageUrl = await ref.getDownloadURL();
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
