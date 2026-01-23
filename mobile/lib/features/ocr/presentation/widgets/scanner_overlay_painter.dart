import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// A premium scanner overlay with Navy mask and Gold accents.
/// Replaces the "crude" yellow border.
class ScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Color borderColor;
  final double borderRadius;

  ScannerOverlayPainter({
    this.overlayColor = const Color.fromRGBO(13, 36, 73, 0.8), // Navy 80%
    this.borderColor = Colors.white, // Strictly White per style guide
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    final width = size.width;
    final height = size.height;

    // Defined scanned area (standard passport ratio ~125mm x 88mm)
    // Adjust for screen
    final scanWidth = width * 0.9;
    final scanHeight = scanWidth * 0.70; // Passport ratio
    final left = (width - scanWidth) / 2;
    final top = (height - scanHeight) / 2;

    // Draw the dark overlay excluding the rounded rect (cutout)
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanWidth, scanHeight),
        Radius.circular(borderRadius),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw the "Gold Corners"
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final cornerLength = scanWidth * 0.1;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top)
        ..lineTo(left + cornerLength, top),
      borderPaint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(left + scanWidth - cornerLength, top)
        ..lineTo(left + scanWidth, top)
        ..lineTo(left + scanWidth, top + cornerLength),
      borderPaint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanHeight - cornerLength)
        ..lineTo(left, top + scanHeight)
        ..lineTo(left + cornerLength, top + scanHeight),
      borderPaint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(left + scanWidth - cornerLength, top + scanHeight)
        ..lineTo(left + scanWidth, top + scanHeight)
        ..lineTo(left + scanWidth, top + scanHeight - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
