import 'package:mobile/models/dashboard_data.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardData();
  Future<Map<String, dynamic>> getProfileData();
  Future<void> updateApplication(Map<String, dynamic> updates);
  Future<void> createApplication(Map<String, dynamic> data);
}
