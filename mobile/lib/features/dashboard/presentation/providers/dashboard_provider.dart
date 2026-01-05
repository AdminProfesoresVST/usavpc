import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_data.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDashboardData();
});
