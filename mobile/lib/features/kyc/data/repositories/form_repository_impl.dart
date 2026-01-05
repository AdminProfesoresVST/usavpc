import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/kyc/domain/entities/form_schema.dart';
import 'package:mobile/features/kyc/domain/repositories/form_repository.dart';

class FormRepositoryImpl implements FormRepository {
  @override
  Future<List<FormStepSchema>> getFormSteps() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const FormStepSchema(
        title: 'Identity',
        schema: {
          'fields': [
            {'key': 'firstName', 'type': 'text', 'label': 'First Name'},
            {'key': 'lastName', 'type': 'text', 'label': 'Last Name'},
            {'key': 'dob', 'type': 'date', 'label': 'Date of Birth'},
          ]
        },
      ),
      const FormStepSchema(
        title: 'Contact',
        schema: {
          'fields': [
            {'key': 'email', 'type': 'text', 'label': 'Email Address'},
            {'key': 'phone', 'type': 'text', 'label': 'Phone Number'},
          ]
        },
      ),
    ];
  }
}

final formRepositoryProvider = Provider<FormRepository>((ref) {
  return FormRepositoryImpl();
});
