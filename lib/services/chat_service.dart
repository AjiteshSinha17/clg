import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat.dart';
import '../models/chat_media.dart';
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create or get existing chat with another user
  Future<String> createChat(String otherUserId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not logged in');

    // Check if chat already exists
    final querySnapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in querySnapshot.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new chat
    final docRef = await _firestore.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts': {currentUserId: 0, otherUserId: 0},
    });

    return docRef.id;
  }

  /// Send a message
  Future<void> sendMessage(String chatId, String content) async {
    final currentUserId = _auth.currentUser?.uid;
    final user = _auth.currentUser;
    if (currentUserId == null || user == null)
      throw Exception('User not logged in');

    // Load chat to identify other participants for unread counts
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatSnap = await chatRef.get();
    final chatData = chatSnap.data() ?? {};
    final participants = List<String>.from(chatData['participants'] ?? []);
    final otherParticipants = participants.where((id) => id != currentUserId);

    // Add message to subcollection
    await chatRef.collection('messages').add({
      'chatId': chatId,
      'senderId': currentUserId,
      'senderName': user.displayName ?? 'Unknown',
      'senderAvatarUrl': user.photoURL ?? '',
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'text',
    });

    // Update chat document and increment unread counts for other participants
    final Map<String, dynamic> unreadUpdates = {};
    for (final uid in otherParticipants) {
      unreadUpdates['unreadCounts.$uid'] = FieldValue.increment(1);
    }
    unreadUpdates['unreadCounts.$currentUserId'] = 0;

    await chatRef.update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      ...unreadUpdates,
    });
  }

  /// Mark this chat as read for current user (sets unread count to 0)
  Future<void> markChatRead(String chatId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCounts.$currentUserId': 0,
    });
  }

  /// Get stream of chats for current user
  Stream<List<Chat>> getChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();
        });
  }

  /// Get stream of messages for a chat
  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromFirestore(doc))
              .toList();
        });
  }

  /// Send a media message (image or PDF). Upload URL and optional fileName must be provided.
  Future<void> sendMediaMessage(
    String chatId,
    String type, // 'image' | 'pdf'
    String fileUrl, {
    String? fileName,
    String? caption,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    final user = _auth.currentUser;
    if (currentUserId == null || user == null) throw Exception('User not logged in');

    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatSnap = await chatRef.get();
    final participants = List<String>.from(chatSnap.data()?['participants'] ?? []);
    final otherParticipants = participants.where((id) => id != currentUserId);

    final content = caption ?? (type == 'image' ? 'Image' : 'PDF');
    final msgRef = await chatRef.collection('messages').add({
      'chatId': chatId,
      'senderId': currentUserId,
      'senderName': user.displayName ?? 'Unknown',
      'senderAvatarUrl': user.photoURL ?? '',
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName ?? (type == 'pdf' ? 'document.pdf' : 'image.jpg'),
    });

    // Save to chat_media for download section (link + sender name/id)
    await _firestore.collection('chat_media').add({
      'chatId': chatId,
      'messageId': msgRef.id,
      'senderId': currentUserId,
      'senderName': user.displayName ?? 'Unknown',
      'fileUrl': fileUrl,
      'fileName': fileName ?? (type == 'pdf' ? 'document.pdf' : 'image.jpg'),
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final Map<String, dynamic> unreadUpdates = {};
    for (final uid in otherParticipants) {
      unreadUpdates['unreadCounts.$uid'] = FieldValue.increment(1);
    }
    unreadUpdates['unreadCounts.$currentUserId'] = 0;
    await chatRef.update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      ...unreadUpdates,
    });
  }

  /// Stream of media (download section) for a personal chat
  Stream<List<ChatMedia>> getMediaStream(String chatId) {
    return _firestore
        .collection('chat_media')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMedia.fromFirestore(d)).toList());
  }
}
