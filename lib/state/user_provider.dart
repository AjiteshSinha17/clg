
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user.dart' as app_user;

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  app_user.User? _user;
  bool _isLoading = false;

  app_user.User? get user => _user;
  bool get isLoading => _isLoading;

  UserProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = app_user.User.fromFirestore(doc);
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({required String name, String? bio}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'bio': bio,
      });
      await _loadUserProfile(uid);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
