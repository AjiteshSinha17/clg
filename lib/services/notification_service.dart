import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Top-level function for background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This runs when app is in background or terminated
  debugPrint('Background message received: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool _initialized = false;
  static bool _foregroundListenerRegistered = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      // Request permissions (Android 13+ / iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        final token = await _messaging.getToken();
        if (token != null) {
          await _saveToken(token);
        }

        // Handle token refresh
        _messaging.onTokenRefresh.listen((t) async {
          await _saveToken(t);
        });

        // Configure background message handler
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Store tokens in users/{uid}.fcmTokens
    await _firestore.collection('users').doc(user.uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'updatedAt': FieldValue.serverTimestamp(),
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
    }, SetOptions(merge: true));
  }

  /// Listen for foreground messages. Pass [messengerKey] from MaterialApp so
  /// SnackBar is shown even when user has navigated to another screen.
  void listenForeground(GlobalKey<ScaffoldMessengerState>? messengerKey) {
    if (_foregroundListenerRegistered) return;
    _foregroundListenerRegistered = true;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      final title = notif?.title ?? message.data['title'] ?? 'Notification';
      final body = notif?.body ?? message.data['body'] ?? '';

      final messenger = messengerKey?.currentState ?? null;
      if (messenger != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(body.isEmpty ? title : '$title: $body'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    // Optional: handle when user taps notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Could navigate to a specific route based on message.data
      debugPrint('Notification opened: ${message.messageId}');
    });
  }
}

