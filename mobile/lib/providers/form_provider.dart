import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/services/form_repository_impl.dart';
import 'package:mobile/models/form_schema.dart';

final formStepsProvider = FutureProvider<List<FormStepSchema>>((ref) async {
  final repo = ref.watch(formRepositoryProvider);
  return repo.getFormSteps();
});
