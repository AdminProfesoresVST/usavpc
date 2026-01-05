import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

// We override the provider in the test to avoid calling real repo.
// We can use overrides in ProviderScope.

void main() {
  testWidgets('LoginScreen validation errors appear', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Tap verify without entering text
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Please enter email'), findsOneWidget);
    expect(find.text('Please enter password'), findsOneWidget);
  });
  
  testWidgets('LoginScreen shows loading indicator', (tester) async {
      // TODO: Mock the notifier state to be loading to verify UI Update
  });
}
