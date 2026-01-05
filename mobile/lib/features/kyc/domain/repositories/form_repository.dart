import 'package:mobile/features/kyc/domain/entities/form_schema.dart';

abstract class FormRepository {
  Future<List<FormStepSchema>> getFormSteps();
}
