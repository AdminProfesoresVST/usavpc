import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/kyc/data/repositories/form_repository_impl.dart';
import 'package:mobile/features/kyc/domain/entities/form_schema.dart';
import 'package:mobile/features/kyc/domain/repositories/form_repository.dart';
import 'package:mobile/features/kyc/presentation/screens/form_wizard_screen.dart';
import 'package:mobile/features/kyc/presentation/widgets/dynamic_section.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

// Mock Repository
class MockFormRepository implements FormRepository {
  @override
  Future<List<FormStepSchema>> getFormSteps() async {
    return [
      FormStepSchema(
        title: 'Identity',
        schema: {
          'fields': [
            {'key': 'firstName', 'type': 'text', 'label': 'First Name'}
          ]
        },
      ),
      FormStepSchema(
        title: 'Contact',
        schema: {
          'fields': [
            {'key': 'email', 'type': 'text', 'label': 'Email Address'}
          ]
        },
      ),
    ];
  }
}

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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          formRepositoryProvider.overrideWithValue(MockFormRepository()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: FormWizardScreen(),
        ),
      ),
    );
    
    // Wait for mock data
    await tester.pumpAndSettle();

    expect(find.text('Identity'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);

    // Tap Continue 
    // Note: Stepper continue button might be labeled "Continue" or "Next"
    // We try to find the button at the bottom of the active step.
    // The default Stepper uses Text buttons.
    await tester.tap(find.text('Continue').last); 
    await tester.pumpAndSettle();

    expect(find.text('Email Address'), findsOneWidget); // Step 1 content visible
  });
}
