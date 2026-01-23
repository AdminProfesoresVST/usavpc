import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/rpa/presentation/screens/automation_progress_screen.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('AutomationProgressScreen renders header and progress', (tester) async {
    // Skipping this test because AutomationProgressScreen invokes WebViewController in initState,
    // which requires native platform channels not available in standard widget tests without 
    // extensive mocking of the WebViewPlatform interface.
    // extensive mocking of the WebViewPlatform interface.
    return;
  }, skip: true);
  
  testWidgets('AutomationProgressScreen renders header and progress', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: AutomationProgressScreen(),
        ),
      ),
    );

    // Header title from app_en.arb: "ds160AutoFill": "DS-160 AUTO-FILL"
    expect(find.text('DS-160 AUTO-FILL'), findsOneWidget);
    
    // Progress indicator should be present
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Note: We do not test specific log messages here because they are driven by 
    // real WebViewController events which do not fire in a widget test environment 
    // without extensive platform mocking.
  });
}
