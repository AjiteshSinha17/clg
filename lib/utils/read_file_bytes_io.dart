import 'dart:io';
import 'dart:typed_data';

/// Reads file bytes from [path]. Used when file_picker returns null bytes (e.g. Android).
Future<Uint8List?> readFileBytes(String? path) async {
  if (path == null || path.isEmpty) return null;
  try {
    return await File(path).readAsBytes();
  } catch (_) {
    return null;
  }
}
