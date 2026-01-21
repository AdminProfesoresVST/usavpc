import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardData> getDashboardData() async {
    return const DashboardData(
      status: 'DRAFT',
      progress: 0.2,
      lastEdited: '2h ago',
      nextSteps: [
        DashboardAction(
          title: 'Upload Documents',
          subtitle: 'Required for next step',
          iconCode: 'upload_file',
        ),
        DashboardAction(
          title: 'Pay Visa Details',
          subtitle: 'Finalize application',
          iconCode: 'payment',
        ),
      ],
    );
  }
}

void main() {
  testWidgets('DashboardScreen renders status card and actions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(MockDashboardRepository()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DashboardScreen(),
        ),
      ),
    );

    // Wait for FutureProvider to resolve
    await tester.pumpAndSettle();

    // Verify localized headers (assuming English default)
    expect(find.text('Application Status'), findsOneWidget);
    expect(find.text('Next Steps'), findsOneWidget);

    // Verify content from Mock
    expect(find.text('Draft'), findsOneWidget); // Status is uppercase in UI -> TitleCase in l10n
    expect(find.text('20% Complete'), findsOneWidget); // Formatted percentage
    
    // Verify actions
    expect(find.text('Upload Documents'), findsOneWidget);
    expect(find.text('Pay Visa Details'), findsOneWidget);
  });
}
