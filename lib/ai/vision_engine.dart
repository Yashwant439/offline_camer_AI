import 'package:path/path.dart' as p;

import '../domain/entities.dart';

abstract class VisionEngine {
  Future<List<DetectedObject>> detectObjects(String imagePath);
}

class MockVisionEngine implements VisionEngine {
  @override
  Future<List<DetectedObject>> detectObjects(String imagePath) async {
    final label = _guessLabelFromFilename(imagePath);
    return [
      DetectedObject(
        name: label ?? 'Unknown Object',
        confidence: label == null ? 0.15 : 0.62,
        boundingBox: BoundingBox.full(),
      ),
    ];
  }

  String? _guessLabelFromFilename(String path) {
    final name = p.basename(path).toLowerCase();
    if (name.contains('mango')) return 'Mango';
    if (name.contains('pizza')) return 'Pizza';
    if (name.contains('dog')) return 'Dog';
    if (name.contains('laptop')) return 'Laptop';
    return null;
  }
}