import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document for download section: stores file link with sender name/id.
class ChatMedia {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String fileUrl;
  final String fileName;
  final String type; // 'image' | 'pdf'
  final DateTime timestamp;

  ChatMedia({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.fileUrl,
    required this.fileName,
    required this.type,
    required this.timestamp,
  });

  factory ChatMedia.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMedia(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileName: data['fileName'] ?? '',
      type: data['type'] ?? 'file',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
