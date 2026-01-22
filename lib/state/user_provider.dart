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
      } else {
        // If user doc doesn't exist (e.g. created via auth but not firestore), create it
        // This handles the edge case where registration might have failed halfway
        final email = _auth.currentUser?.email ?? '';
        final newUser = app_user.User(
          uid: uid,
          email: email,
          name: 'User', // Default name
          college: '',
          branch: '',
          year: '',
          avatarUrl: '',
          bannerUrl: '',
          bio: '',
        );

        // Save to firestore
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'name': 'User',
          'college': '',
          'branch': '',
          'year': '',
          'bio': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _user = newUser;
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Set a temporary user object so the app doesn't get stuck in loading
      if (_auth.currentUser != null) {
        _user = app_user.User(
          uid: uid,
          email: _auth.currentUser!.email ?? '',
          name: 'User',
          college: '',
          branch: '',
          year: '',
          avatarUrl: '',
          bannerUrl: '',
          bio: '',
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    required String name,
    String? bio,
    String? college,
    String? branch,
    String? year,
    String? avatarUrl,
    String? bannerUrl,
    String? collegeIdImageUrl,
    String? verificationStatus,
    // Roommate Fields
    bool? isLookingForRoommate,
    String? city,
    String? area,
    double? budgetMin,
    double? budgetMax,
    List<String>? interestTags,
    String? sleepSchedule,
    int? cleanlinessLevel,
    String? smoking,
    String? drinking,
    bool? livesAlone,
    String? preferredGender,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final uid = _auth.currentUser!.uid;
      final Map<String, dynamic> data = {'name': name, 'bio': bio};

      if (college != null) data['college'] = college;
      if (branch != null) data['branch'] = branch;
      if (year != null) data['year'] = year;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      if (bannerUrl != null) data['bannerUrl'] = bannerUrl;
      if (collegeIdImageUrl != null)
        data['collegeIdImageUrl'] = collegeIdImageUrl;
      if (verificationStatus != null)
        data['verificationStatus'] = verificationStatus;

      // Roommate Fields
      if (isLookingForRoommate != null)
        data['isLookingForRoommate'] = isLookingForRoommate;
      if (city != null) data['city'] = city;
      if (area != null) data['area'] = area;
      if (budgetMin != null) data['budgetMin'] = budgetMin;
      if (budgetMax != null) data['budgetMax'] = budgetMax;
      if (interestTags != null) data['interestTags'] = interestTags;
      if (sleepSchedule != null) data['sleepSchedule'] = sleepSchedule;
      if (cleanlinessLevel != null) data['cleanlinessLevel'] = cleanlinessLevel;
      if (smoking != null) data['smoking'] = smoking;
      if (drinking != null) data['drinking'] = drinking;
      if (livesAlone != null) data['livesAlone'] = livesAlone;
      if (preferredGender != null) data['preferredGender'] = preferredGender;

      await _firestore.collection('users').doc(uid).update(data);
      await _loadUserProfile(uid);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
