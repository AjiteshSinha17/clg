import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InAppNotificationService {
  static final InAppNotificationService _instance = InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription? _msgSub;
  StreamSubscription? _reqSub;
  bool _initialized = false;
  GlobalKey<ScaffoldMessengerState>? _messengerKey;

  void init(GlobalKey<ScaffoldMessengerState> messengerKey) {
    if (_initialized) return;
    _messengerKey = messengerKey;
    _initialized = true;

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _startListening(user.uid);
      } else {
        _stopListening();
      }
    });
  }

  void _startListening(String uid) {
    _stopListening(); // Ensure clean state

    _msgSub = _firestore
        .collection('personal_message_notifications')
        .where('receiverId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;
          
          final createdAt = data['createdAt'] as Timestamp?;
          // Wait for server timestamp to resolve or ignore if older than 30 secs
          if (createdAt == null) continue;
          if (DateTime.now().difference(createdAt.toDate()).inSeconds > 30) {
             continue; // ignore old messages
          }
          final preview = data['preview'] ?? 'New message';
          _showSnackbar('💬 New Message: $preview');
        }
      }
    });

    _reqSub = _firestore
        .collection('connection_requests')
        .where('toUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;
          
          final createdAt = data['createdAt'] as Timestamp?;
          // Wait for server timestamp to resolve or ignore if older than 30 secs
          if (createdAt == null) continue;
          if (DateTime.now().difference(createdAt.toDate()).inSeconds > 30) {
             continue; // ignore old requests
          }
          _showSnackbar('🤝 New connection request received!');
        }
      }
    });
  }

  void _stopListening() {
    _msgSub?.cancel();
    _reqSub?.cancel();
  }

  void _showSnackbar(String message) {
    if (_messengerKey?.currentState != null) {
      _messengerKey!.currentState!.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
