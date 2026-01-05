import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  @override
  Future<DashboardData> getDashboardData() async {
    // Simulate DB Fetch
    await Future.delayed(const Duration(milliseconds: 500));
    
    return const DashboardData(
      status: 'DRAFT',
      progress: 0.2, // 20%
      lastEdited: '2h ago',
      nextSteps: [
        DashboardAction(
          title: 'Upload Documents', 
          subtitle: 'Passport and Photo needed', 
          iconCode: 'upload_file'
        ),
        DashboardAction(
          title: 'Pay Visa Details', 
          subtitle: 'Select your plan', 
          iconCode: 'payment'
        ),
      ],
    );
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl();
});
