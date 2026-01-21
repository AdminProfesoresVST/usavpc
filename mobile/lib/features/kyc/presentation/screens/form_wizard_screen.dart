import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/kyc/presentation/providers/form_provider.dart';
import 'package:mobile/features/kyc/presentation/widgets/dynamic_section.dart';

/// Form wizard screen with full i18n support.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
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
    final l10n = context.l10n;
    final stepsAsync = ref.watch(formStepsProvider);

    return Scaffold(
      appBar: AppHeader(title: l10n.newVisaApplication),
      body: stepsAsync.when(
        data: (steps) {
            if (steps.isEmpty) return Center(child: Text(l10n.noPlansAvailable));

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
        error: (err, stack) => Center(child: Text(l10n.error(err.toString()))),
      ),
    );
  }
}
