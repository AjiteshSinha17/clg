import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../models/community_content.dart';
import '../services/community_content_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

class CommunityContentProvider with ChangeNotifier {
  final CommunityContentService _contentService = CommunityContentService();
  final StorageService _storageService = StorageService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CommunityContent> _contentList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CommunityContent> get contentList => _contentList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load public content stream
  Stream<List<CommunityContent>> getPublicContentStream({
    String? category,
    String? subject,
    String? college,
    String? branch,
    List<String>? tags,
    int? limit,
  }) {
    return _contentService.getPublicContentStream(
      category: category,
      subject: subject,
      college: college,
      branch: branch,
      tags: tags,
      limit: limit,
    );
  }

  /// Create new community content
  Future<void> createContent({
    required String title,
    String? description,
    required String contentType, // 'note', 'pdf', 'image', 'mixed'
    required List<File> files,
    String? thumbnailFile,
    String? category,
    List<String>? tags,
    String? subject,
    String? college,
    String? branch,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get user info
      final userDoc = await _userService.getUserProfile(user.uid);
      final userName = userDoc?.name ?? 'Anonymous';
      final userAvatarUrl = userDoc?.avatarUrl ?? '';

      // Upload files
      final List<String> fileUrls = [];
      String? thumbnailUrl;

      for (var file in files) {
        String url;
        if (contentType == 'pdf') {
          final bytes = await file.readAsBytes();
          url = await _storageService.uploadPDFBytes(user.uid, bytes);
        } else if (contentType == 'image') {
          final bytes = await file.readAsBytes();
          url = await _storageService.uploadCommunityImageBytes(user.uid, bytes);
        } else {
          final bytes = await file.readAsBytes();
          url = await _storageService.uploadCommunityFileBytes(user.uid, bytes);
        }
        fileUrls.add(url);
      }

      // Upload thumbnail if provided
      if (thumbnailFile != null) {
        final thumbnailFileObj = File(thumbnailFile);
        final bytes = await thumbnailFileObj.readAsBytes();
        thumbnailUrl = await _storageService.uploadCommunityImageBytes(
          user.uid,
          bytes,
          fileName: 'thumbnail.jpg',
        );
      }

      // Create content object
      final content = CommunityContent(
        id: '', // Will be set by Firestore
        authorId: user.uid,
        authorName: userName,
        authorAvatarUrl: userAvatarUrl,
        title: title,
        description: description,
        contentType: contentType,
        fileUrls: fileUrls,
        thumbnailUrl: thumbnailUrl,
        category: category,
        tags: tags ?? [],
        subject: subject,
        college: college,
        branch: branch,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _contentService.createContent(content);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update content
  Future<void> updateContent(
    String contentId,
    Map<String, dynamic> updates,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _contentService.updateContent(contentId, updates);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete content
  Future<void> deleteContent(String contentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _contentService.deleteContent(contentId);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Increment view count
  Future<void> viewContent(String contentId) async {
    try {
      await _contentService.incrementViewCount(contentId);
    } catch (e) {
      // Silently fail for view count
      debugPrint('Failed to increment view count: $e');
    }
  }

  /// Increment download count
  Future<void> downloadContent(String contentId) async {
    try {
      await _contentService.incrementDownloadCount(contentId);
    } catch (e) {
      debugPrint('Failed to increment download count: $e');
    }
  }

  /// Toggle like
  Future<void> toggleLike(String contentId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    _isLoading = true;
    notifyListeners();

    try {
      await _contentService.toggleLike(contentId, user.uid);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get content by author
  Future<List<CommunityContent>> getContentByAuthor(String authorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final content = await _contentService.getContentByAuthor(authorId);
      return content;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search content
  Future<List<CommunityContent>> searchContent(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _contentService.searchContent(query);
      return results;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pick files using file_picker
  Future<List<File>> pickFiles({
    bool allowMultiple = true,
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to pick files: $e');
    }
  }

  /// Pick images using image_picker
  Future<List<File>> pickImages({bool allowMultiple = true}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<File> images = [];

      if (allowMultiple) {
        final pickedFiles = await picker.pickMultiImage();
        for (var pickedFile in pickedFiles) {
          images.add(File(pickedFile.path));
        }
      } else {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          images.add(File(pickedFile.path));
        }
      }

      return images;
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
