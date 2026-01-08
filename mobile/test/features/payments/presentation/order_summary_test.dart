import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/payments/presentation/screens/order_summary_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('OrderSummaryScreen renders items and correct total', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OrderSummaryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('US Visa Strategy Review (DIY)'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('\$49.00'), findsOneWidget); // 39 + 10
    expect(find.text('Pay with Apple Pay'), findsOneWidget);
  });
}
