import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class ImageUtils {
  static Future<Uint8List> loadAndResize(String path, int size) async {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes;
    }
    final resized = img.copyResize(decoded, width: size, height: size);
    return Uint8List.fromList(img.encodeJpg(resized));
  }

  static Future<void> validateImageFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Image file not found.');
    }
    final ext = p.extension(path).toLowerCase();
    const allowed = ['.jpg', '.jpeg', '.png'];
    if (!allowed.contains(ext)) {
      throw Exception('Unsupported image format.');
    }
    final size = await file.length();
    const maxSize = 10 * 1024 * 1024;
    if (size > maxSize) {
      throw Exception('Image file too large.');
    }
  }
}
