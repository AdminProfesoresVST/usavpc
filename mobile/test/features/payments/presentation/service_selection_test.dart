import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/payments/presentation/screens/service_selection_screen.dart';
import 'package:mobile/features/payments/presentation/widgets/service_card.dart';

void main() {
  testWidgets('ServiceSelectionScreen renders grid of services', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        // In a real test, we would override servicePlansProvider with a mock
        // For now we act against the 'simulated' repository delay
        child: MaterialApp(
          home: ServiceSelectionScreen(),
        ),
      ),
    );

    // Initial load - show spinner
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for the simulated delay
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Choose your visa type'), findsOneWidget);
    expect(find.byType(ServiceCard), findsWidgets);
    expect(find.text('B1/B2 Tourist Visa'), findsOneWidget); // Checks mock data
  });

  testWidgets('ServiceCard shows popular badge when enabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ServiceCard(
            title: 'Test',
            price: '\$10',
            description: 'Desc',
            onTap: () {},
            isPopular: true,
          ),
        ),
      ),
    );

    expect(find.text('Popular'), findsOneWidget);
  });
}
