import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/kyc/presentation/providers/form_provider.dart';
import 'package:mobile/features/kyc/presentation/widgets/dynamic_section.dart';

class FormWizardScreen extends ConsumerStatefulWidget {
  const FormWizardScreen({super.key});

  @override
  ConsumerState<FormWizardScreen> createState() => _FormWizardScreenState();
}

class _FormWizardScreenState extends ConsumerState<FormWizardScreen> {
  int _currentStep = 0;
  final Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    final stepsAsync = ref.watch(formStepsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Visa Application')),
      body: stepsAsync.when(
        data: (steps) {
            if (steps.isEmpty) return const Center(child: Text('No steps configured'));

            return Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < steps.length - 1) {
                  setState(() => _currentStep++);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: steps.map((step) {
                return Step(
                  title: Text(step.title),
                  content: DynamicSection(
                    schema: step.schema,
                    initialData: _formData,
                    onChanged: (key, value) {
                      _formData[key] = value;
                    },
                  ),
                  isActive: _currentStep >= steps.indexOf(step),
                );
              }).toList(),
            );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
