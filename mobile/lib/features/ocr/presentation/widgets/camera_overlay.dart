import 'package:flutter/material.dart';

class CameraOverlay extends StatelessWidget {
  const CameraOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: OverlayPainter(),
      child: Container(),
    );
  }
}

class OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    
    // Draw semi-transparent background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw clear rect for passport
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.9,
      height: size.height * 0.3,
    );
    
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRect(cutoutRect, clearPaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(cutoutRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
