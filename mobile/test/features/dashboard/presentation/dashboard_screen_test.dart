import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/presentation/screens/dashboard_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('DashboardScreen renders status card', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DashboardScreen())));

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Application Status'), findsOneWidget);
    expect(find.text('DRAFT'), findsOneWidget);
    expect(find.text('20% Complete'), findsOneWidget);
  });
  
  testWidgets('DashboardScreen renders action tiles', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: DashboardScreen())));
    
    await tester.pumpAndSettle(const Duration(seconds: 1));
    
    expect(find.text('Next Steps'), findsOneWidget);
    expect(find.text('Upload Documents'), findsOneWidget);
    expect(find.text('Pay Visa Details'), findsOneWidget);
  });
}
