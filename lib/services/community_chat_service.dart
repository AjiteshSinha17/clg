import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_media.dart';
import '../models/message.dart';

class CommunityChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String globalRoomId = 'global';

  Stream<List<Message>> getMessagesStream({String roomId = globalRoomId}) {
    return _firestore
        .collection('community_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => Message.fromFirestore(d)).toList(),
        );
  }

  Future<void> sendMessage(
    String content, {
    String roomId = globalRoomId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final roomRef = _firestore.collection('community_rooms').doc(roomId);

    // Ensure room exists
    await roomRef.set({
      'id': roomId,
      'name': roomId == globalRoomId ? 'Community' : roomId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await roomRef.collection('messages').add({
      'chatId': roomId,
      'senderId': user.uid,
      'senderName':
          user.displayName ?? (user.email?.split('@').first ?? 'User'),
      'senderAvatarUrl': user.photoURL ?? '',
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': true,
      'type': 'text',
    });

    await roomRef.set({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // [DEBUG] Confirm community message was written
    debugPrint(
      '[CommunityChatService] Text message sent to room=$roomId by user=${user.uid}',
    );
  }

  /// Send image or PDF in community chat
  Future<void> sendMediaMessage(
    String type, // 'image' | 'pdf'
    String fileUrl, {
    String roomId = globalRoomId,
    String? fileName,
    String? caption,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final roomRef = _firestore.collection('community_rooms').doc(roomId);
    await roomRef.set({
      'id': roomId,
      'name': roomId == globalRoomId ? 'Community' : roomId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final content = caption ?? (type == 'image' ? 'Image' : 'PDF');
    final msgRef = await roomRef.collection('messages').add({
      'chatId': roomId,
      'senderId': user.uid,
      'senderName':
          user.displayName ?? (user.email?.split('@').first ?? 'User'),
      'senderAvatarUrl': user.photoURL ?? '',
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': true,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName ?? (type == 'pdf' ? 'document.pdf' : 'image.jpg'),
    });

    await _firestore.collection('community_media').add({
      'roomId': roomId,
      'messageId': msgRef.id,
      'senderId': user.uid,
      'senderName':
          user.displayName ?? (user.email?.split('@').first ?? 'User'),
      'fileUrl': fileUrl,
      'fileName': fileName ?? (type == 'pdf' ? 'document.pdf' : 'image.jpg'),
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await roomRef.set({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // [DEBUG] Confirm community media message was written
    debugPrint(
      '[CommunityChatService] Media ($type) sent to room=$roomId by user=${user.uid}, fileUrl=$fileUrl',
    );
  }

  /// Stream of media (download section) for community chat
  Stream<List<ChatMedia>> getMediaStream({String roomId = globalRoomId}) {
    return _firestore
        .collection('community_media')
        .where('roomId', isEqualTo: roomId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => _communityMediaFromFirestore(d)).toList(),
        );
  }

  static ChatMedia _communityMediaFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMedia(
      id: doc.id,
      chatId: data['roomId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileName: data['fileName'] ?? '',
      type: data['type'] ?? 'file',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
