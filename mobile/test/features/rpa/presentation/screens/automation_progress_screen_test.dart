import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/rpa/presentation/screens/automation_progress_screen.dart';
import 'package:mobile/features/rpa/presentation/providers/automation_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Mocking WebView for UI tests is complex. We verify structure mainly.
void main() {
  testWidgets('AutomationProgressScreen renders header', (WidgetTester tester) async {
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
          home: AutomationProgressScreen(),
        ),
      ),
    );

    // Assert
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    // Note: WebViewPlatform might throw if not mocked, but for smoke test we check static elements before webview init completes or fail gracefully.
  });
}
