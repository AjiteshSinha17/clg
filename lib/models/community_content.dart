import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for community content (notes, PDFs, images) shared in community and people sections
class CommunityContent {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  
  // Content details
  final String title;
  final String? description;
  final String contentType; // 'note', 'pdf', 'image', 'mixed'
  
  // File URLs
  final List<String> fileUrls; // URLs for PDFs, images, or other files
  final String? thumbnailUrl; // Thumbnail for PDFs or preview image
  
  // Metadata
  final String? category; // e.g., 'study_notes', 'lecture_slides', 'resources'
  final List<String> tags; // Tags for searchability
  final String? subject; // Subject/course name
  final String? college; // College name
  final String? branch; // Branch/department
  
  // Engagement
  final int downloadCount;
  final int viewCount;
  final int likeCount;
  final List<String> likedBy; // User IDs who liked this content
  
  // Status
  final bool isPublic; // Whether content is visible to all or just community
  final bool isApproved; // For moderation
  final bool isActive; // Soft delete flag
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  CommunityContent({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl = '',
    required this.title,
    this.description,
    required this.contentType,
    required this.fileUrls,
    this.thumbnailUrl,
    this.category,
    this.tags = const [],
    this.subject,
    this.college,
    this.branch,
    this.downloadCount = 0,
    this.viewCount = 0,
    this.likeCount = 0,
    this.likedBy = const [],
    this.isPublic = true,
    this.isApproved = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityContent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommunityContent(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorAvatarUrl: data['authorAvatarUrl'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      contentType: data['contentType'] ?? 'note',
      fileUrls: List<String>.from(data['fileUrls'] ?? []),
      thumbnailUrl: data['thumbnailUrl'],
      category: data['category'],
      tags: List<String>.from(data['tags'] ?? []),
      subject: data['subject'],
      college: data['college'],
      branch: data['branch'],
      downloadCount: data['downloadCount'] ?? 0,
      viewCount: data['viewCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      isPublic: data['isPublic'] ?? true,
      isApproved: data['isApproved'] ?? true,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'title': title,
      if (description != null) 'description': description,
      'contentType': contentType,
      'fileUrls': fileUrls,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (category != null) 'category': category,
      'tags': tags,
      if (subject != null) 'subject': subject,
      if (college != null) 'college': college,
      if (branch != null) 'branch': branch,
      'downloadCount': downloadCount,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'likedBy': likedBy,
      'isPublic': isPublic,
      'isApproved': isApproved,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CommunityContent copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    String? title,
    String? description,
    String? contentType,
    List<String>? fileUrls,
    String? thumbnailUrl,
    String? category,
    List<String>? tags,
    String? subject,
    String? college,
    String? branch,
    int? downloadCount,
    int? viewCount,
    int? likeCount,
    List<String>? likedBy,
    bool? isPublic,
    bool? isApproved,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityContent(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      fileUrls: fileUrls ?? this.fileUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      subject: subject ?? this.subject,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      downloadCount: downloadCount ?? this.downloadCount,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      isPublic: isPublic ?? this.isPublic,
      isApproved: isApproved ?? this.isApproved,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
