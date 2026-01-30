import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/ocr/presentation/screens/verification_scanner_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mock Camera packages not strictly necessary for UI smoke test if we just check structure but heavily dependent on camera plugin.
// For Full Spectrum Audit, we verify the screen builds.

void main() {
  testWidgets('VerificationScannerScreen renders instructions', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: VerificationScannerScreen(),
        ),
      ),
    );

    // Assert
    expect(find.text('Center your photo page'), findsOneWidget); // Matches l10n.passportScanInstructions default
  });
}
