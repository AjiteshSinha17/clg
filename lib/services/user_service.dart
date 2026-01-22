import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'avatarUrl': avatarUrl ?? '',
        'bio': '',
        'college': '',
        'branch': '',
        'year': '',
        'gender': 'prefer_not_to_say',
        'verificationStatus': 'not_verified',
        'collegeIdImageUrl': '',
        'profileCompleted': false,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? avatarUrl,
    String? bio,
    String? college,
    String? branch,
    String? year,
    String? gender,
    bool? profileCompleted,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      if (bio != null) updates['bio'] = bio;
      if (college != null) updates['college'] = college;
      if (branch != null) updates['branch'] = branch;
      if (year != null) updates['year'] = year;
      if (gender != null) updates['gender'] = gender;
      if (profileCompleted != null) {
        updates['profileCompleted'] = profileCompleted;
      }

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Get user profile by UID
  Future<User?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail - not critical
      print('Failed to update last login: $e');
    }
  }

  /// Upload college ID for verification
  Future<void> uploadCollegeId({
    required String uid,
    required String imageUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'collegeIdImageUrl': imageUrl,
        'verificationStatus': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to upload college ID: $e');
    }
  }

  /// Update verification status (admin function)
  Future<void> updateVerificationStatus({
    required String uid,
    required String status,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'verificationStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update verification status: $e');
    }
  }

  /// Search users by college
  Future<List<User>> searchUsersByCollege(String college) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('college', isEqualTo: college)
          .where('isActive', isEqualTo: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  /// Stream user profile changes
  Stream<User?> streamUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? User.fromFirestore(doc) : null);
  }
}
