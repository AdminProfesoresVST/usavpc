import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/service_locator/app_config.dart';
import 'package:mobile/core/service_locator/app_config_provider.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Create a mock config for testing
    final testConfig = AppConfig(
      appName: 'US Visa Test',
      flavor: Flavor.dev,
      apiBaseUrl: 'https://test.api',
      supabaseUrl: 'https://test.supabase.co',
      supabaseAnonKey: 'test-key',
      netlifyFunctionsUrl: 'https://test.netlify',
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
        ],
        child: MyApp(config: testConfig),
      ),
    );

    // Verify that the splash screen appears (or whatever the home is)
    // Since default route is /splash, we expect the splash content or loading
    // Just verifying it pumps without error is a good smoke test.
    await tester.pumpAndSettle();
  });
}
