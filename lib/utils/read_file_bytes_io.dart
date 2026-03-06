import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Reads file bytes from [path]. Used when file_picker returns null bytes (e.g. Android).
Future<Uint8List?> readFileBytes(String? path) async {
  if (path == null || path.isEmpty) return null;
  try {
    if (defaultTargetPlatform == TargetPlatform.android &&
        path.startsWith('content://')) {
      final bytes = await const MethodChannel(
        'content_uri_reader',
      ).invokeMethod<Uint8List>('readBytes', {'uri': path});
      return bytes;
    }
    return await File(path).readAsBytes();
  } catch (_) {
    return null;
  }
}
