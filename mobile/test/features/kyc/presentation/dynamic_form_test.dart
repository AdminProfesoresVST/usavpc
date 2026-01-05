import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/kyc/presentation/screens/form_wizard_screen.dart';
import 'package:mobile/features/kyc/presentation/widgets/dynamic_section.dart';

void main() {
  testWidgets('DynamicSection renders fields based on schema', (tester) async {
    const schema = {
      'fields': [
        {'key': 'f1', 'type': 'text', 'label': 'Field One'},
        {'key': 'f2', 'type': 'text', 'label': 'Field Two'},
      ]
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicSection(
            schema: schema,
            onChanged: (k, v) {},
          ),
        ),
      ),
    );

    expect(find.text('Field One'), findsOneWidget);
    expect(find.text('Field Two'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('FormWizardScreen shows stepper and navigates', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: FormWizardScreen())));
    
    // Wait for mock data
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget); // Step 0 content is visible
    expect(find.text('Contact'), findsOneWidget);

    // Tap Continue (First one found is usually the active controls)
    await tester.tap(find.text('Continue').first);
    await tester.pumpAndSettle();

    expect(find.text('Email Address'), findsOneWidget); // Step 1 content now visible
  });
}
