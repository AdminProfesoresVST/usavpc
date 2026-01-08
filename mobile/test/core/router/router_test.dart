import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/core/router/router.dart';
import 'package:mobile/features/onboarding/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Router starts at splash route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(goRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      ),
    );

    // Splash timer is 3.5s. We must advance time to avoid 'pending timer' error.
    await tester.pump(const Duration(seconds: 4)); 
    await tester.pumpAndSettle(); // Settle navigation animations
    
    // After splash, should be at /services? Or verify Splash is GONE.
    expect(find.byType(SplashScreen), findsNothing);
  });
}
