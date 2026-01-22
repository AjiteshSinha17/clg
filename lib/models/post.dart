import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String authorId;
  final String userName;
  final String userAvatarUrl;
  final DateTime timestamp;
  final int likes;
  final int comments;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl = '',
    required this.authorId,
    required this.userName,
    this.userAvatarUrl = '',
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      authorId: data['authorId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatarUrl: data['userAvatarUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
    );
  }

  /// Create a [Post] from a plain map and an explicit id.
  factory Post.fromMap(Map<String, dynamic> data, String id) {
    return Post(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      authorId: data['authorId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userAvatarUrl: data['userAvatarUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'authorId': authorId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments,
    };
  }
}
