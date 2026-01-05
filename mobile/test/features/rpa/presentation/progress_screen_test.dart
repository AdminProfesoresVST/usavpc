import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/rpa/presentation/screens/automation_progress_screen.dart';

void main() {
  testWidgets('AutomationProgressScreen shows logs and progress', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AutomationProgressScreen(),
      ),
    );

    expect(find.text('AUTO-FILLING DS-160'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Fast forward animation/timer - total 3 seconds
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('> Initializing Browser Environment...'), findsOneWidget);
    
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('> Injecting User Data...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('> Form Submitted Successfully.'), findsOneWidget);
    
    // We do NOT use pumpAndSettle here because HackingModeOverlay has an infinite repeating animation
    // which would cause pumpAndSettle to hang or layout specific errors.
    await tester.pump(const Duration(milliseconds: 100));
  });
}
