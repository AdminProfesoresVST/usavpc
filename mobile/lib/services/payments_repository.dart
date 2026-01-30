import 'package:mobile/models/service_plan.dart';

abstract class PaymentsRepository {
  Future<List<ServicePlan>> getServicePlans();
}
