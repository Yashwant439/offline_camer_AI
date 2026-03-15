import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_providers.dart';
import '../core/app_routes.dart';
import '../domain/entities.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionControllerProvider);
    final session = state.session;
    if (session == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No detection yet.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final top = state.detections.isNotEmpty ? state.detections.first : null;
    final knowledge = top?.knowledge;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              children: [
                Positioned.fill(child: Image.file(File(session.imagePath))),
                Positioned.fill(
                  child: CustomPaint(
                    painter: DetectionPainter(state.detections),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    top?.name ?? 'Unknown Object',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (top?.confidence ?? 0).clamp(0, 1),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confidence: ${((top?.confidence ?? 0) * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Divider(height: 24),
                  Text(
                    knowledge?.description ??
                        'No local description available yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (knowledge != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Season: ${knowledge.season}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Health: ${knowledge.healthInfo}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
              icon: const Icon(Icons.mic),
              label: const Text('Ask Questions'),
            ),
          ),
        ],
      ),
    );
  }
}

class DetectionPainter extends CustomPainter {
  DetectionPainter(this.detections);

  final List<DetectedObject> detections;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF0B6B6B);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final detection in detections) {
      final box = detection.boundingBox;
      final rect = Rect.fromLTWH(
        box.left * size.width,
        box.top * size.height,
        box.width * size.width,
        box.height * size.height,
      );
      canvas.drawRect(rect, paint);
      textPainter.text = TextSpan(
        text: detection.name,
        style: const TextStyle(
          color: Color(0xFF0B6B6B),
          backgroundColor: Colors.white,
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, rect.topLeft + const Offset(4, 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
