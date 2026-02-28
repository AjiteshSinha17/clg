import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get user's notification preferences
  Future<NotificationPreferences> getPreferences() async {
    final user = _auth.currentUser;
    if (user == null) {
      return NotificationPreferences.defaults();
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      return NotificationPreferences.defaults();
    }

    final data = doc.data();
    final prefs = data?['notificationPreferences'] as Map<String, dynamic>?;

    if (prefs == null) {
      // Save defaults if not set
      final defaults = NotificationPreferences.defaults();
      await setPreferences(defaults);
      return defaults;
    }

    return NotificationPreferences.fromMap(prefs);
  }

  /// Update user's notification preferences
  Future<void> setPreferences(NotificationPreferences prefs) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'notificationPreferences': prefs.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream of notification preferences (for real-time updates)
  Stream<NotificationPreferences> preferencesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(NotificationPreferences.defaults());
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return NotificationPreferences.defaults();
      }

      final data = doc.data();
      final prefs = data?['notificationPreferences'] as Map<String, dynamic>?;

      if (prefs == null) {
        return NotificationPreferences.defaults();
      }

      return NotificationPreferences.fromMap(prefs);
    });
  }
}

class NotificationPreferences {
  final bool personalChatEnabled;
  final bool communityChatEnabled;
  final bool roommateRequestEnabled;

  const NotificationPreferences({
    required this.personalChatEnabled,
    required this.communityChatEnabled,
    required this.roommateRequestEnabled,
  });

  factory NotificationPreferences.defaults() {
    return const NotificationPreferences(
      personalChatEnabled: true,
      communityChatEnabled: true,
      roommateRequestEnabled: true,
    );
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      personalChatEnabled: map['personalChatEnabled'] ?? true,
      communityChatEnabled: map['communityChatEnabled'] ?? true,
      roommateRequestEnabled: map['roommateRequestEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'personalChatEnabled': personalChatEnabled,
      'communityChatEnabled': communityChatEnabled,
      'roommateRequestEnabled': roommateRequestEnabled,
    };
  }

  NotificationPreferences copyWith({
    bool? personalChatEnabled,
    bool? communityChatEnabled,
    bool? roommateRequestEnabled,
  }) {
    return NotificationPreferences(
      personalChatEnabled: personalChatEnabled ?? this.personalChatEnabled,
      communityChatEnabled: communityChatEnabled ?? this.communityChatEnabled,
      roommateRequestEnabled: roommateRequestEnabled ?? this.roommateRequestEnabled,
    );
  }
}
