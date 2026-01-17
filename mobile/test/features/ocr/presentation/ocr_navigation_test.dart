import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/service_locator/app_config.dart';
import 'package:mobile/core/service_locator/app_config_provider.dart';
import 'package:mobile/features/ocr/presentation/screens/verification_landing_screen.dart';

// Mock Config
final mockConfig = AppConfig(
  appName: 'Test App',
  flavor: Flavor.dev,
  apiBaseUrl: 'https://test.com',
  supabaseUrl: 'https://test.supabase.co',
  supabaseAnonKey: 'test-key',
  netlifyFunctionsUrl: 'https://test.netlify.app',
);

void main() {
  testWidgets('Identity Verification Config Must Load Landing Screen', (WidgetTester tester) async {
    // Build App with Router, starting at /identity/start
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(mockConfig),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/identity/start',
            routes: [
              GoRoute(
                path: '/identity/start',
                builder: (context, state) => const VerificationLandingScreen(),
              ),
              GoRoute(
                path: '/identity/capture',
                builder: (context, state) => const Placeholder(), // Cameraless mock
              ),
            ],
          ),
        ),
      ),
    );

    // Allow animations to settle
    await tester.pumpAndSettle();

    // 1. Verify we are on the Intro Screen
    expect(find.text('VERIFICACIÓN DE IDENTIDAD'), findsOneWidget);
    
    // 2. Verify we see the instructions
    expect(find.text('Prepare su Documento'), findsOneWidget);
    
    // 3. Verify Buttons
    expect(find.text('ESCANEAR CON CÁMARA'), findsOneWidget);

    debugPrint('✅ TEST PASSED: Verification Landing Screen loaded correctly.');
  });
}
