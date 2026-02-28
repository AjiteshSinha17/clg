import 'package:cloud_firestore/cloud_firestore.dart';

/// Message type: text, image, or pdf (stored as download link in Firestore).
enum MessageType { text, image, pdf }

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderAvatarUrl;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  /// For image/pdf: download link stored in Firestore.
  final String? fileUrl;
  /// For image/pdf: display name of file.
  final String? fileName;
  /// text | image | pdf
  final MessageType type;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
    this.type = MessageType.text,
  });

  bool get isMedia => type == MessageType.image || type == MessageType.pdf;

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final typeStr = data['type'] as String?;
    MessageType type = MessageType.text;
    if (typeStr == 'image') type = MessageType.image;
    if (typeStr == 'pdf') type = MessageType.pdf;

    return Message(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      senderAvatarUrl: data['senderAvatarUrl'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      type: type,
    );
  }

  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type.name,
    };
    if (imageUrl != null) map['imageUrl'] = imageUrl;
    if (fileUrl != null) map['fileUrl'] = fileUrl;
    if (fileName != null) map['fileName'] = fileName;
    return map;
  }
}
