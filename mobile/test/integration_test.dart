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

  testWidgets('Full App Flow: Launch -> Dashboard -> Profile', (tester) async {
    // 1. Launch App (Simulate main())
    // We wrap in ProviderScope because MyApp likely expects it or we want to ensure it's there.
    // If main() already wraps it, we might double wrap, which is usually fine or we just pump MyApp.
    // Let's assume we construct MyApp directly.
    
    await tester.pumpWidget(
      ProviderScope(
        child: MyApp(
          config: AppConfig(
             appName: 'TestApp',
             apiBaseUrl: 'https://test.api',
             supabaseUrl: 'https://test.supabase',
             supabaseAnonKey: 'test-key',
             flavor: Flavor.dev,
          ),
        ),
      ),
    );

    // 2. Wait for Dashboard Load (Async Repos)
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 3. Verify Dashboard
    expect(find.widgetWithText(AppBar, 'Dashboard'), findsOneWidget);
    expect(find.text('Application Status'), findsOneWidget);
    expect(find.text('DRAFT'), findsOneWidget); // Default mock data

    // 4. Navigate to Profile (Bottom Nav)
    final profileTab = find.byIcon(Icons.person);
    expect(profileTab, findsOneWidget);
    await tester.tap(profileTab);
    
    await tester.pumpAndSettle();

    // 5. Verify Profile Screen
    expect(find.text('John Doe'), findsOneWidget); // Mock Profile Data
    expect(find.text('Logout'), findsOneWidget);
  });
}
