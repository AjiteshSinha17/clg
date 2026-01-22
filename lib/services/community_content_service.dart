import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_content.dart';

class CommunityContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'community_content';

  /// Create a new community content entry
  Future<String> createContent(CommunityContent content) async {
    try {
      final docRef = await _firestore.collection(_collection).add(content.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create community content: $e');
    }
  }

  /// Update existing content
  Future<void> updateContent(String contentId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(contentId).update(updates);
    } catch (e) {
      throw Exception('Failed to update community content: $e');
    }
  }

  /// Delete content (soft delete by setting isActive to false)
  Future<void> deleteContent(String contentId) async {
    try {
      await _firestore.collection(_collection).doc(contentId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to delete community content: $e');
    }
  }

  /// Get a single content by ID
  Future<CommunityContent?> getContentById(String contentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(contentId).get();
      if (doc.exists && doc.data() != null) {
        return CommunityContent.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get community content: $e');
    }
  }

  /// Get stream of all active public content
  Stream<List<CommunityContent>> getPublicContentStream({
    String? category,
    String? subject,
    String? college,
    String? branch,
    List<String>? tags,
    int? limit,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('isPublic', isEqualTo: true)
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (subject != null && subject.isNotEmpty) {
      query = query.where('subject', isEqualTo: subject);
    }

    if (college != null && college.isNotEmpty) {
      query = query.where('college', isEqualTo: college);
    }

    if (branch != null && branch.isNotEmpty) {
      query = query.where('branch', isEqualTo: branch);
    }

    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    }

    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CommunityContent.fromFirestore(doc))
          .toList();
    });
  }

  /// Get content by author
  Future<List<CommunityContent>> getContentByAuthor(String authorId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('authorId', isEqualTo: authorId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CommunityContent.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get content by author: $e');
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String contentId) async {
    try {
      await _firestore.collection(_collection).doc(contentId).update({
        'viewCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  /// Increment download count
  Future<void> incrementDownloadCount(String contentId) async {
    try {
      await _firestore.collection(_collection).doc(contentId).update({
        'downloadCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to increment download count: $e');
    }
  }

  /// Toggle like on content
  Future<void> toggleLike(String contentId, String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(contentId).get();
      if (!doc.exists) throw Exception('Content not found');

      final data = doc.data()!;
      final List<String> likedBy = List<String>.from(data['likedBy'] ?? []);

      if (likedBy.contains(userId)) {
        // Unlike
        likedBy.remove(userId);
        await _firestore.collection(_collection).doc(contentId).update({
          'likedBy': likedBy,
          'likeCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Like
        likedBy.add(userId);
        await _firestore.collection(_collection).doc(contentId).update({
          'likedBy': likedBy,
          'likeCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  /// Search content by title or description
  Future<List<CommunityContent>> searchContent(String searchQuery) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation. For production, consider using Algolia or similar
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .where('isApproved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final query = searchQuery.toLowerCase();
      return snapshot.docs
          .map((doc) => CommunityContent.fromFirestore(doc))
          .where((content) {
            return content.title.toLowerCase().contains(query) ||
                (content.description?.toLowerCase().contains(query) ?? false) ||
                content.tags.any((tag) => tag.toLowerCase().contains(query));
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to search content: $e');
    }
  }
}
