import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/connection_request.dart';
import 'chat_service.dart';

/// Connection flow: send request -> accept/reject -> on accept create chat.
/// Firestore: connection_requests { fromUserId, toUserId, status, createdAt, updatedAt }.
class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  static const String _collection = 'connection_requests';

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Send a connection request from current user to [toUserId].
  /// Fails if already pending/accepted or if sending to self.
  Future<void> sendRequest(String toUserId) async {
    final from = _currentUserId;
    if (from == null) throw Exception('User not logged in');
    if (from == toUserId) throw Exception('Cannot send request to yourself');

    final existing = await _getRequestBetween(from, toUserId);
    if (existing != null) {
      if (existing.isPending) throw Exception('Request already sent');
      if (existing.isAccepted) throw Exception('Already connected');
      throw Exception('Request was previously ${existing.status.name}');
    }

    await _firestore.collection(_collection).add({
      'fromUserId': from,
      'toUserId': toUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Accept a request. Creates a chat and returns chatId so UI can navigate.
  Future<String> acceptRequest(String requestId) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not logged in');

    final ref = _firestore.collection(_collection).doc(requestId);
    final doc = await ref.get();
    if (!doc.exists) throw Exception('Request not found');

    final req = ConnectionRequest.fromFirestore(doc);
    if (req.toUserId != uid) throw Exception('Not allowed to accept this request');
    if (!req.isPending) throw Exception('Request is no longer pending');

    await ref.update({
      'status': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create chat between the two users (idempotent: createChat returns existing if any)
    final chatId = await _chatService.createChat(req.fromUserId);
    return chatId;
  }

  /// Reject a request.
  Future<void> rejectRequest(String requestId) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not logged in');

    final ref = _firestore.collection(_collection).doc(requestId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final req = ConnectionRequest.fromFirestore(doc);
    if (req.toUserId != uid) throw Exception('Not allowed to reject this request');
    if (!req.isPending) return;

    await ref.update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get connection status between current user and [otherUserId].
  /// Returns: none | pending_sent | pending_received | accepted
  Future<String> getConnectionStatus(String otherUserId) async {
    final uid = _currentUserId;
    if (uid == null) return 'none';

    final req = await _getRequestBetween(uid, otherUserId);
    if (req == null) return 'none';
    if (req.isAccepted) return 'accepted';
    if (req.isPending) {
      return req.fromUserId == uid ? 'pending_sent' : 'pending_received';
    }
    return 'none';
  }

  /// Get the accepted connection request between current user and other (if any).
  /// Used to know if we can open chat (and get chatId via createChat).
  Future<ConnectionRequest?> getAcceptedRequestBetween(String otherUserId) async {
    final uid = _currentUserId;
    if (uid == null) return null;

    final req = await _getRequestBetween(uid, otherUserId);
    return req != null && req.isAccepted ? req : null;
  }

  Future<ConnectionRequest?> _getRequestBetween(String a, String b) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('fromUserId', isEqualTo: a)
        .where('toUserId', isEqualTo: b)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      final reverse = await _firestore
          .collection(_collection)
          .where('fromUserId', isEqualTo: b)
          .where('toUserId', isEqualTo: a)
          .limit(1)
          .get();
      if (reverse.docs.isEmpty) return null;
      return ConnectionRequest.fromFirestore(reverse.docs.first);
    }
    return ConnectionRequest.fromFirestore(snapshot.docs.first);
  }

  /// Stream of pending requests sent TO current user (for "Requests" screen).
  Stream<List<ConnectionRequest>> getPendingRequestsToMeStream() {
    final uid = _currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection(_collection)
        .where('toUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ConnectionRequest.fromFirestore(d)).toList());
  }

  /// One-time fetch of pending requests to me (for badge or initial load).
  Future<List<ConnectionRequest>> getPendingRequestsToMe() async {
    final uid = _currentUserId;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection(_collection)
        .where('toUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((d) => ConnectionRequest.fromFirestore(d)).toList();
  }
}
