import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/payments/presentation/screens/service_selection_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('ServiceSelectionScreen renders main services', (WidgetTester tester) async {
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
          home: ServiceSelectionScreen(),
        ),
      ),
    );

    // Assert
    expect(find.byIcon(Icons.contact_page), findsOneWidget); // New Application card
    expect(find.byIcon(Icons.forum), findsOneWidget); // Simulator card
  });
}
