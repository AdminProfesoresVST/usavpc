import 'package:mobile/features/dashboard/domain/entities/dashboard_data.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardData();
}
