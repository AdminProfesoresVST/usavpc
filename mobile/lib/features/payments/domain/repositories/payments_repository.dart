import 'package:mobile/features/payments/domain/entities/service_plan.dart';

abstract class PaymentsRepository {
  Future<List<ServicePlan>> getServicePlans();
}
