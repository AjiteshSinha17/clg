import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal integration:
/// - init OneSignal SDK
/// - request permission
/// - save device subscription id to Firestore (users/{uid}.oneSignalId)
class OneSignalService {
  static bool _initialized = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Set this to your OneSignal App ID.
  static const String oneSignalAppId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: '',
  );

  Future<void> init({required String appId}) async {
    if (_initialized) return;
    _initialized = true;

    OneSignal.initialize(appId);

    // Ask permission (iOS + Android 13+)
    await OneSignal.Notifications.requestPermission(true);

    // Foreground: show notification
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.notification.display();
    });
  }

  /// Save current device OneSignal subscription id for the logged-in user.
  Future<void> syncCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final id = OneSignal.User.pushSubscription.id;
    if (id == null || id.isEmpty) {
      // [DEBUG] No OneSignal subscription ID available yet
      debugPrint('[OneSignalService] No subscription ID for user=${user.uid}');
      return;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'oneSignalId': id,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // [DEBUG] Confirm OneSignal ID saved
    debugPrint(
      '[OneSignalService] Saved OneSignal ID=$id for user=${user.uid}',
    );
  }
}
