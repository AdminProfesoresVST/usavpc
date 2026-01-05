import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/ocr/presentation/widgets/camera_overlay.dart';

void main() {
  testWidgets('CameraOverlay draws custom paint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CameraOverlay(),
        ),
      ),
    );

    expect(find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is OverlayPainter), findsOneWidget);
  });
}
