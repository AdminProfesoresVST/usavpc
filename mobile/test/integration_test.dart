import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart'; // Import main app widget (need to export it or create a testable one)
import 'package:mobile/core/service_locator/app_config.dart';

// We assume main.dart has a MyApp widget. If not, we might need to verify main.dart content.
// Based on previous file edits, 'main.dart' was created.

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized(); // Removed for headless run

  testWidgets('App Launch Flow: Splash -> Service Selection', (tester) async {
    // 1. Launch App (Simulate main())
    
    await tester.pumpWidget(
      ProviderScope(
        child: MyApp(
          config: AppConfig(
             appName: 'TestApp',
             apiBaseUrl: 'https://test.api',
             supabaseUrl: 'https://test.supabase',
             supabaseAnonKey: 'test-key',
             netlifyFunctionsUrl: 'https://test.netlify',
             flavor: Flavor.dev,
          ),
        ),
      ),
    );

    // 2. Wait for Splash (3.5s) + Animation
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 3. Verify Landing on Service Selection (Simulated User)
    expect(find.text('Simplifica tu Trámite Consular'), findsOneWidget);
    expect(find.text('Guía Oficial'), findsOneWidget);
    
    // 4. Verify Service Cards Present
    expect(find.text('Nueva Solicitud de Visa'), findsOneWidget);
  });
}
