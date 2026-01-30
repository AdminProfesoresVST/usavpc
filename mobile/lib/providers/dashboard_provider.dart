import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/services/dashboard_repository_impl.dart';
import 'package:mobile/models/dashboard_data.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDashboardData();
});
