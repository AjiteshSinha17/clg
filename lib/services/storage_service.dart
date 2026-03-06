import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../config/backend_config.dart';
import '../config/cloudinary_config.dart';

/// StorageService now uses **Cloudinary** instead of Firebase Storage.
/// It keeps the same public API so the rest of the app can stay unchanged.
class StorageService {
  // 5 MB for images, 10 MB for PDFs by default.
  static const int _maxImageBytes = 5 * 1024 * 1024;
  static const int _maxPdfBytes = 10 * 1024 * 1024;

  String get _cloudName => CloudinaryConfig.cloudName;
  String get _uploadPreset => CloudinaryConfig.uploadPreset;

  /// Basic path sanitization so we don’t create weird Cloudinary public_ids.
  static String _sanitizePathSegment(String segment) {
    if (segment.isEmpty) return 'unknown';
    return segment.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_');
  }

  Uri _buildUri(String resourceType) {
    // resourceType: 'image' for images, 'raw' for PDFs/other files
    return Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );
  }

  static String _stripExtension(String fileName) {
    return fileName.replaceFirst(RegExp(r'\.[^.]+$'), '');
  }

  /// Returns null if signer is not configured or returns an error (e.g. 404).
  /// Caller can fall back to unsigned upload.
  Future<Map<String, dynamic>?> _getSignedUploadParams({
    required String folder,
    required String publicId,
    required int timestamp,
  }) async {
    final baseUrl = BackendConfig.baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    if (baseUrl.isEmpty) {
      return null;
    }

    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final idToken = await user.getIdToken();
      final uri = Uri.parse('$baseUrl/cloudinary/sign-upload');
      final resp = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'folder': folder,
          'publicId': publicId,
          'timestamp': timestamp,
          'type': 'upload',
        }),
      );

      if (resp.statusCode != 200) {
        debugPrint('[StorageService] Signer returned ${resp.statusCode}: ${resp.body}');
        return null;
      }

      final decoded = jsonDecode(resp.body);
      if (decoded is! Map) return null;
      return decoded.cast<String, dynamic>();
    } catch (e) {
      debugPrint('[StorageService] Signer error: $e');
      return null;
    }
  }

  Future<String> _uploadBytesSigned({
    required Uint8List bytes,
    required String fileName,
    required String folder,
    required String resourceType,
    required int maxBytes,
    required String contextLabel,
  }) async {
    if (_cloudName.isEmpty) {
      throw Exception(
        'Cloudinary is not configured. Set cloudName in CloudinaryConfig.',
      );
    }

    if (bytes.lengthInBytes > maxBytes) {
      final mb = (maxBytes / (1024 * 1024)).toStringAsFixed(0);
      throw Exception('File too large for $contextLabel. Max $mb MB.');
    }

    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final publicId = _sanitizePathSegment(_stripExtension(fileName));

    final sign = await _getSignedUploadParams(
      folder: folder,
      publicId: publicId,
      timestamp: ts,
    );

    if (sign == null) {
      // Signer not available (e.g., not deployed yet / wrong URL). Fall back to
      // unsigned upload so the app can still function.
      return _uploadBytes(
        bytes: bytes,
        fileName: fileName,
        folder: folder,
        resourceType: resourceType,
        maxBytes: maxBytes,
        contextLabel: contextLabel,
      );
    }

    final signature = sign['signature'] as String?;
    final apiKey = sign['apiKey'] as String?;
    final cloudName = sign['cloudName'] as String?;
    final timestamp = sign['timestamp'];
    final type = (sign['type'] as String?) ?? 'upload';

    final tsStr = (timestamp is num) ? timestamp.toInt().toString() : '$timestamp';
    if (signature == null ||
        signature.isEmpty ||
        apiKey == null ||
        apiKey.isEmpty ||
        cloudName == null ||
        cloudName.isEmpty ||
        tsStr.isEmpty) {
      throw Exception('Signer response missing fields');
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = tsStr
      ..fields['signature'] = signature
      ..fields['folder'] = folder
      ..fields['public_id'] = publicId
      ..fields['type'] = type
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Cloudinary upload failed for $contextLabel: '
        '${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final url = data['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception(
        'Cloudinary response missing secure_url for $contextLabel',
      );
    }
    return url;
  }

  Future<String> _uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String folder,
    required String resourceType,
    required int maxBytes,
    required String contextLabel,
  }) async {
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      throw Exception(
        'Cloudinary is not configured. Set cloudName and uploadPreset in CloudinaryConfig.',
      );
    }

    if (bytes.lengthInBytes > maxBytes) {
      final mb = (maxBytes / (1024 * 1024)).toStringAsFixed(0);
      throw Exception('File too large for $contextLabel. Max $mb MB.');
    }

    final uri = _buildUri(resourceType);
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Cloudinary upload failed for $contextLabel: '
        '${response.statusCode} ${response.body}',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final url = data['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception(
        'Cloudinary response missing secure_url for $contextLabel',
      );
    }
    return url;
  }

  // -------- Image uploads (cross-platform: Web + Mobile) --------

  Future<String> uploadProfileImageXFile(String userId, XFile imageFile) async {
    final safeId = _sanitizePathSegment(userId);
    final bytes = await imageFile.readAsBytes();
    return _uploadBytes(
      bytes: bytes,
      fileName: 'profile_$safeId.jpg',
      folder: 'profile_images/$safeId',
      resourceType: 'image',
      maxBytes: _maxImageBytes,
      contextLabel: 'profile image',
    );
  }

  Future<String> uploadCollegeIdXFile(String userId, XFile imageFile) async {
    final safeId = _sanitizePathSegment(userId);
    final bytes = await imageFile.readAsBytes();
    return _uploadBytes(
      bytes: bytes,
      fileName: 'college_id_$safeId.jpg',
      folder: 'college_ids/$safeId',
      resourceType: 'image',
      maxBytes: _maxImageBytes,
      contextLabel: 'college ID',
    );
  }

  Future<String> uploadBannerImageXFile(String userId, XFile imageFile) async {
    final safeId = _sanitizePathSegment(userId);
    final bytes = await imageFile.readAsBytes();
    return _uploadBytes(
      bytes: bytes,
      fileName: 'banner_$safeId.jpg',
      folder: 'profile_banners/$safeId',
      resourceType: 'image',
      maxBytes: _maxImageBytes,
      contextLabel: 'banner image',
    );
  }

  /// Upload a PDF file for community content (stored as Cloudinary "raw" resource).
  Future<String> uploadPDFBytes(
    String userId,
    Uint8List bytes, {
    String? fileName,
  }) async {
    final safeId = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'document_$ts.pdf');
    return _uploadBytes(
      bytes: bytes,
      fileName: name,
      folder: 'community_content/pdfs/$safeId',
      resourceType: 'raw',
      maxBytes: _maxPdfBytes,
      contextLabel: 'PDF',
    );
  }

  /// Upload an image file for community content.
  Future<String> uploadCommunityImageBytes(
    String userId,
    Uint8List bytes, {
    String? fileName,
  }) async {
    final safeId = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = (fileName?.split('.').last ?? 'jpg').toLowerCase();
    final name = _sanitizePathSegment(fileName ?? 'image_$ts.$ext');
    return _uploadBytes(
      bytes: bytes,
      fileName: name,
      folder: 'community_content/images/$safeId',
      resourceType: 'image',
      maxBytes: _maxImageBytes,
      contextLabel: 'community image',
    );
  }

  /// Upload any file type for community content (notes, documents, etc.).
  Future<String> uploadCommunityFileBytes(
    String userId,
    Uint8List bytes, {
    String? fileName,
    String? contentType,
  }) async {
    final safeId = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = (fileName?.split('.').last ?? 'file').toLowerCase();
    final name = _sanitizePathSegment(fileName ?? 'file_$ts.$ext');
    final isPdf = ext == 'pdf';
    return _uploadBytes(
      bytes: bytes,
      fileName: name,
      folder: 'community_content/files/$safeId',
      resourceType: isPdf ? 'raw' : 'image',
      maxBytes: isPdf ? _maxPdfBytes : _maxImageBytes,
      contextLabel: 'file',
    );
  }

  /// Upload multiple files at once.
  Future<List<String>> uploadMultipleFileBytes(
    String userId,
    List<Uint8List> filesBytes,
  ) async {
    try {
      final List<String> urls = [];
      for (var bytes in filesBytes) {
        final url = await uploadCommunityFileBytes(
          userId,
          bytes,
          fileName: null,
        );
        urls.add(url);
      }
      return urls;
    } catch (e) {
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  /// Upload image for personal chat. Returns Cloudinary URL.
  Future<String> uploadChatImage(
    String chatId,
    String userId,
    Uint8List bytes, {
    String? fileName,
  }) async {
    final safeChat = _sanitizePathSegment(chatId);
    final safeUser = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'image_${safeUser}_$ts.jpg');
    return _uploadBytesSigned(
      bytes: bytes,
      fileName: name,
      folder: 'chat_media/personal/$safeChat',
      resourceType: 'image',
      maxBytes: _maxImageBytes,
      contextLabel: 'chat image',
    );
  }

  /// Upload PDF for personal chat. Returns Cloudinary URL.
  Future<String> uploadChatPdf(
    String chatId,
    String userId,
    Uint8List bytes, {
    String? fileName,
  }) async {
    final safeChat = _sanitizePathSegment(chatId);
    final safeUser = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'doc_${safeUser}_$ts.pdf');
    return _uploadBytesSigned(
      bytes: bytes,
      fileName: name,
      folder: 'chat_media/personal/$safeChat',
      resourceType: 'raw',
      maxBytes: _maxPdfBytes,
      contextLabel: 'chat PDF',
    );
  }

  /// Upload image for community chat.
  Future<String> uploadCommunityChatImage(
    String roomId,
    String userId,
    Uint8List bytes, {
    String? fileName,
  }) async {
    final safeRoom = _sanitizePathSegment(roomId);
    final safeUser = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'image_${safeUser}_$ts.jpg');
    return _uploadBytesSigned(
      bytes: bytes,
      fileName: name,
      folder: 'chat_media/community/$safeRoom',
      resourceType: 'image',
      maxBytes: _maxImageBytes,
      contextLabel: 'community chat image',
    );
  }

  /// Upload PDF for community chat.
  Future<String> uploadCommunityChatPdf(
    String roomId,
    String userId,
    Uint8List bytes, {
    String? fileName,
  }) async {
    final safeRoom = _sanitizePathSegment(roomId);
    final safeUser = _sanitizePathSegment(userId);
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = _sanitizePathSegment(fileName ?? 'doc_${safeUser}_$ts.pdf');
    return _uploadBytesSigned(
      bytes: bytes,
      fileName: name,
      folder: 'chat_media/community/$safeRoom',
      resourceType: 'raw',
      maxBytes: _maxPdfBytes,
      contextLabel: 'community chat PDF',
    );
  }

  /// Delete is not implemented for Cloudinary from the client because it
  /// requires the API secret. If you need deletes, expose a secure backend
  /// endpoint that performs authenticated deletions.
  Future<void> deleteFile(String fileUrl) async {
    debugPrint('deleteFile called for $fileUrl but is a no-op on client.');
  }
}
