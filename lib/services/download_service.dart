import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable download service for downloading images and PDFs from Cloudinary.
/// Downloads files to the device and opens them automatically.
class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();

  /// PDFs are now uploaded as Cloudinary 'image' resource type so that their
  /// delivery URLs are publicly accessible (res.cloudinary.com/image/upload/...).
  ///
  /// Some older PDFs may have been uploaded as 'raw' resource type which isn't
  /// publicly served by default and causes ERR_INVALID_RESPONSE. This helper
  /// rewrites those old /raw/upload/ URLs → /image/upload/ so they can be
  /// fetched and displayed correctly.
  static String normalizeCloudinaryPdfUrl(String url) {
    final isPdf = url.toLowerCase().endsWith('.pdf');
    final hasRawPath = url.contains('/raw/upload/');
    if (isPdf && hasRawPath) {
      // Old raw-type PDF → rewrite to image for public accessibility
      return url.replaceFirst('/raw/upload/', '/image/upload/');
    }
    return url;
  }

  /// Downloads a file from [url] and saves it locally with [fileName].
  /// Returns the local file path on success, or null on failure.
  /// [onProgress] callback provides download progress (0.0 to 1.0).
  Future<String?> downloadFile(
    String url,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final normalizedUrl = DownloadService.normalizeCloudinaryPdfUrl(url);
      // Get the downloads directory
      final dir = await _getDownloadDirectory();
      if (dir == null) {
        debugPrint('[DownloadService] Could not get download directory');
        return null;
      }

      final filePath = '${dir.path}/$fileName';
      debugPrint('[DownloadService] Downloading $normalizedUrl to $filePath');

      await _dio.download(
        normalizedUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      debugPrint('[DownloadService] Download complete: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('[DownloadService] Download failed: $e');
      return null;
    }
  }

  /// Downloads a file and opens it automatically.
  /// Returns true if successful, false otherwise.
  Future<bool> downloadAndOpenFile(
    String url,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    final path = await downloadFile(url, fileName, onProgress: onProgress);
    if (path == null) {
      return await _fallbackToUrlLauncher(url);
    }

    try {
      final result = await OpenFilex.open(path);
      debugPrint(
        '[DownloadService] OpenFilex result: ${result.type} ${result.message}',
      );
      if (result.type == ResultType.done) {
        return true;
      } else {
        return await _fallbackToUrlLauncher(url);
      }
    } catch (e) {
      debugPrint('[DownloadService] Failed to open file: $e');
      return await _fallbackToUrlLauncher(url);
    }
  }

  Future<bool> _fallbackToUrlLauncher(String url) async {
    try {
      final normalizedUrl = DownloadService.normalizeCloudinaryPdfUrl(url);
      final uri = Uri.parse(normalizedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[DownloadService] Fallback to url_launcher failed: $e');
      return false;
    }
  }

  /// Gets the appropriate download directory for the platform.
  Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Modern Android requires MANAGE_EXTERNAL_STORAGE to write directly
        // to public Downloads directory without Storage Access Framework.
        // It's safer to download to app's external storage first.
        final dirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (dirs != null && dirs.isNotEmpty) {
          return dirs.first;
        }
      }
      // Fallback to app documents directory for iOS and other platforms
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      debugPrint('[DownloadService] Error getting download directory: $e');
      return null;
    }
  }
}
