
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'posts';

  // Create a new post
  Future<void> createPost(String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newPost = {
        'authorId': user.uid,
        'content': content,
        'timestamp': Timestamp.now(),
        'likeCount': 0,
      };
      await _db.collection(_collectionPath).add(newPost);
    }
  }

  // Get a stream of all public posts
  Stream<List<Post>> getPostsStream() {
    return _db
        .collection(_collectionPath)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // The document ID is the post ID
        return Post.fromMap(data, doc.id);
      }).toList();
    });
  }
}
