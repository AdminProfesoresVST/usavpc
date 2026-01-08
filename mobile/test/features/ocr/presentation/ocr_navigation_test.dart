import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/router/router.dart';
import 'package:mobile/core/service_locator/app_config.dart';
import 'package:mobile/core/service_locator/app_config_provider.dart';
import 'package:mobile/features/ocr/presentation/screens/ocr_screen.dart';
import 'package:mobile/features/ocr/presentation/screens/ocr_camera_screen.dart';

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
  testWidgets('OCR Route (/verification-intro) MUST show Intro Screen and NOT Camera', (WidgetTester tester) async {
    // Build App with Router, starting at /verification-intro
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(mockConfig),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/verification-intro',
            routes: [
              GoRoute(
                path: '/verification-intro',
                builder: (context, state) => const OCRScreen(),
                routes: [
                  GoRoute(
                    path: 'scan',
                    builder: (context, state) => const Placeholder(), // Mock Camera Screen to avoid Camera plugin crash
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Allow animations to settle
    await tester.pumpAndSettle();

    // 1. Verify we are on the Intro Screen
    // Title changed to "MODO INTRO" in previous step
    expect(find.text('MODO INTRO'), findsOneWidget);
    
    // 2. Verify we see the buttons
    expect(find.text('USAR CÁMARA'), findsOneWidget);
    expect(find.text('SUBIR DE GALERÍA'), findsOneWidget);

    // 3. Verify Camera is NOT present
    // The CameraMRZWidget is part of OCRCameraScreen, which is at /ocr/scan
    // Since we are at /ocr, it should definitely NOT be here.
    // Also, checking for the old "Escanear Pasaporte" title just in case
    expect(find.text('Escanear Pasaporte'), findsNothing);
    expect(find.text('CÁMARA ACTIVADA'), findsNothing);

    debugPrint('✅ TEST PASSED: OCR Screen loaded correctly in INTRO MODE.');
  });
}
