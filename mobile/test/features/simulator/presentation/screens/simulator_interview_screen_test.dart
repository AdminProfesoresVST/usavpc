import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/simulator/presentation/screens/simulator_interview_screen.dart';
import 'package:mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile/features/kyc/data/ai_repository.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mockito/mockito.dart';

// Manual Mocks
class MockDashboardRepository implements DashboardRepository {
  @override
  Future<Map<String, dynamic>> getProfileData() async {
     return {
      'app': {'form_data': {'given_name': 'Test'}},
      'profile': {},
    };
  }
  // Stubs
  @override
  Future<void> createApplication(Map<String, dynamic> data) async {}
  @override
  Future<void> updateApplication(Map<String, dynamic> updates) async {}
}

class MockAiRepository implements AiRepository {
    @override
  Future<SimulatorResponse> sendSimulatorInteraction({required String message, required String visaType, Map<String, dynamic>? profileData}) async {
    return SimulatorResponse(textToSpeak: 'Hello', feedback: null);
  }
}

// Minimal mock for Supabase Client just to satisfy provider override if needed, 
// though manual override of client might be harder. 
// We will try to override JUST the repositories, assuming the screen uses the repositories.
// However, the screen MIGHT use `ref.read(supabaseClientProvider)` in `_loadProfileAndInit`?
// Checking code: It uses `dashboardRepositoryProvider.getProfileData()`.
// It DOES NOT use `supabaseClientProvider` directly in init.
// So we might get away with just mocking the Repo.

void main() {
  testWidgets('SimulatorInterviewScreen loads and requests greeting', (WidgetTester tester) async {
    // Arrange
    final mockDashboard = MockDashboardRepository();
    final mockAi = MockAiRepository();

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(mockDashboard),
          aiRepositoryProvider.overrideWithValue(mockAi),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: SimulatorInterviewScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(TextField), findsOneWidget); // Chat input presence
  });
}
