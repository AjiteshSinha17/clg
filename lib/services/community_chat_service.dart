import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        .map((snapshot) => snapshot.docs.map((d) => Message.fromFirestore(d)).toList());
  }

  Future<void> sendMessage(String content, {String roomId = globalRoomId}) async {
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
      'senderName': user.displayName ?? (user.email?.split('@').first ?? 'User'),
      'senderAvatarUrl': user.photoURL ?? '',
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': true,
    });

    await roomRef.set({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

