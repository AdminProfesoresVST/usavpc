import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/services/payments_repository_impl.dart';
import 'package:mobile/models/service_plan.dart';

part 'payments_provider.g.dart';

@riverpod
Future<List<ServicePlan>> servicePlans(Ref ref) async {
  final repo = ref.watch(paymentsRepositoryProvider);
  return repo.getServicePlans();
}
