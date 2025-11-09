import 'package:flutter/material.dart';
import '../models/hazard.dart';

class DetectionOverlay extends CustomPainter {
  final List<Detection> detections;
  final Size imageSize;

  DetectionOverlay({
    required this.detections,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var detection in detections) {
      // Scale coordinates to canvas size
      final scaleX = size.width / imageSize.width;
      final scaleY = size.height / imageSize.height;

      final rect = Rect.fromLTWH(
        detection.x * scaleX,
        detection.y * scaleY,
        detection.width * scaleX,
        detection.height * scaleY,
      );

      // Draw bounding box
      canvas.drawRect(rect, paint);

      // Draw label
      final label =
          '${detection.className} ${(detection.confidence * 100).toInt()}%';
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, rect.top - 20),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
