import 'package:mobile/models/form_schema.dart';

abstract class FormRepository {
  Future<List<FormStepSchema>> getFormSteps();
}
