import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ModelStorage {
  Future<Directory> _modelsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'models'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> resolveModelFile(String filename) async {
    final dir = await _modelsDir();
    return File(p.join(dir.path, filename));
  }

  Future<bool> modelExists(String filename) async {
    final file = await resolveModelFile(filename);
    return file.exists();
  }
}
