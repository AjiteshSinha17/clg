import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Sanitize a segment for use in Storage path (avoid empty or invalid refs).
  static String _sanitizePathSegment(String segment) {
    if (segment.isEmpty) return 'unknown';
    return segment.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_');
  }

  /// Upload bytes and return download URL. Surfaces Firebase errors to help debug
  /// "object-not-found" (check: bucket in firebase_options, Storage rules, network).
  static Future<String> _uploadAndGetUrl(
    Reference ref,
    Uint8List bytes, {
    required SettableMetadata metadata,
    String contextLabel = 'file',
  }) async {
    try {
      final task = ref.putData(bytes, metadata);
      await task;
      // Use same ref after successful put to avoid wrong-reference issues
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw Exception(
        'Failed to upload $contextLabel: [${e.plugin}] ${e.code}: ${e.message}. '
        'Check Storage bucket and rules.',
      );
    } catch (e) {
      throw Exception('Failed to upload $contextLabel: $e');
    }
  }

  // -------- Image uploads (cross-platform: Web + Mobile) --------

  Future<String> uploadProfileImageXFile(String userId, XFile imageFile) async {
    final safeId = _sanitizePathSegment(userId);
    final ref = _storage.ref().child('profile_images/$safeId.jpg');
    final bytes = await imageFile.readAsBytes();
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: 'image/jpeg'),
      contextLabel: 'profile image',
    );
  }

  Future<String> uploadCollegeIdXFile(String userId, XFile imageFile) async {
    final safeId = _sanitizePathSegment(userId);
    final ref = _storage.ref().child('college_ids/$safeId.jpg');
    final bytes = await imageFile.readAsBytes();
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: 'image/jpeg'),
      contextLabel: 'college ID',
    );
  }

  Future<String> uploadBannerImageXFile(String userId, XFile imageFile) async {
    final safeId = _sanitizePathSegment(userId);
    final ref = _storage.ref().child('profile_banners/$safeId.jpg');
    final bytes = await imageFile.readAsBytes();
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: 'image/jpeg'),
      contextLabel: 'banner image',
    );
  }

  /// Upload a PDF file for community content
  Future<String> uploadPDFBytes(String userId, Uint8List bytes, {String? fileName}) async {
    final safeId = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'document_$ts.pdf');
    final ref = _storage.ref().child('community_content/pdfs/$safeId/$name');
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: 'application/pdf'),
      contextLabel: 'PDF',
    );
  }

  /// Upload an image file for community content
  Future<String> uploadCommunityImageBytes(String userId, Uint8List bytes, {String? fileName}) async {
    final safeId = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = fileName?.split('.').last ?? 'jpg';
    final name = _sanitizePathSegment(fileName ?? 'image_$ts.$ext');
    final ref = _storage.ref().child('community_content/images/$safeId/$name');
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: 'image/$ext'),
      contextLabel: 'community image',
    );
  }

  /// Upload any file type for community content (notes, documents, etc.)
  Future<String> uploadCommunityFileBytes(String userId, Uint8List bytes, {String? fileName, String? contentType}) async {
    final safeId = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = fileName?.split('.').last ?? 'file';
    final name = _sanitizePathSegment(fileName ?? 'file_$ts.$ext');
    final ref = _storage.ref().child('community_content/files/$safeId/$name');
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: contentType ?? 'application/octet-stream'),
      contextLabel: 'file',
    );
  }

  /// Upload multiple files at once
  Future<List<String>> uploadMultipleFileBytes(String userId, List<Uint8List> filesBytes) async {
    try {
      final List<String> urls = [];
      for (var bytes in filesBytes) {
        final url = await uploadCommunityFileBytes(userId, bytes);
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  /// Upload image for personal chat. Returns download URL.
  Future<String> uploadChatImage(String chatId, String userId, Uint8List bytes, {String? fileName}) async {
    final safeChat = _sanitizePathSegment(chatId);
    final safeUser = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'image_$ts.jpg');
    final ref = _storage.ref().child('chat_media/personal/$safeChat/${safeUser}_${ts}_$name');
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: 'image/jpeg'),
      contextLabel: 'chat image',
    );
  }

  /// Upload PDF for personal chat. Returns download URL.
  Future<String> uploadChatPdf(String chatId, String userId, Uint8List bytes, {String? fileName}) async {
    final safeChat = _sanitizePathSegment(chatId);
    final safeUser = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'doc_$ts.pdf');
    final ref = _storage.ref().child('chat_media/personal/$safeChat/${safeUser}_${ts}_$name');
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: 'application/pdf'),
      contextLabel: 'chat PDF',
    );
  }

  /// Upload image for community chat.
  Future<String> uploadCommunityChatImage(String roomId, String userId, Uint8List bytes, {String? fileName}) async {
    final safeRoom = _sanitizePathSegment(roomId);
    final safeUser = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'image_$ts.jpg');
    final ref = _storage.ref().child('chat_media/community/$safeRoom/${safeUser}_${ts}_$name');
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: 'image/jpeg'),
      contextLabel: 'community chat image',
    );
  }

  /// Upload PDF for community chat.
  Future<String> uploadCommunityChatPdf(String roomId, String userId, Uint8List bytes, {String? fileName}) async {
    final safeRoom = _sanitizePathSegment(roomId);
    final safeUser = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'doc_$ts.pdf');
    final ref = _storage.ref().child('chat_media/community/$safeRoom/${safeUser}_${ts}_$name');
    return _uploadAndGetUrl(
      ref,
      bytes,
      metadata: SettableMetadata(contentType: 'application/pdf'),
      contextLabel: 'community chat PDF',
    );
  }

  /// Delete a file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
