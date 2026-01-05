import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/features/payments/data/repositories/payments_repository_impl.dart';
import 'package:mobile/features/payments/domain/entities/service_plan.dart';

part 'payments_provider.g.dart';

@riverpod
Future<List<ServicePlan>> servicePlans(ServicePlansRef ref) async {
  final repo = ref.watch(paymentsRepositoryProvider);
  return repo.getServicePlans();
}
