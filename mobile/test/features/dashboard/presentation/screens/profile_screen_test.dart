import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Manual Mock
class MockDashboardRepository implements DashboardRepository {
  @override
  Future<Map<String, dynamic>> getProfileData() async {
    return {
      'app': {'form_data': {'given_name': 'TestUser'}},
      'profile': {'email': 'test@example.com'},
      'email': 'test@example.com'
    };
  }
  
  // Implement other methods as throw UnimplementedError or basics
  @override
  Future<void> createApplication(Map<String, dynamic> data) async {}
  
  @override
  Future<void> updateApplication(Map<String, dynamic> updates) async {}
}

void main() {
  testWidgets('ProfileScreen loads loading state then data', (WidgetTester tester) async {
    // Arrange
    final mockRepo = MockDashboardRepository();

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: ProfileScreen(),
        ),
      ),
    );

    // Initial Pump
    await tester.pump();
    
    // Settle (load data)
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('ACCOUNT INFORMATION'), findsOneWidget);
  });
}
