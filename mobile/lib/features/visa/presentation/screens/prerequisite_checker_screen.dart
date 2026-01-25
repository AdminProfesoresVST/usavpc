import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/visa_localization.dart';

import '../../data/models/visa_category.dart';


import '../../data/models/prerequisite_form.dart';
import '../providers/visa_providers.dart';
import '../widgets/document_check_card.dart';

/// Pantalla de verificación de prerrequisitos
class PrerequisiteCheckerScreen extends ConsumerStatefulWidget {
  final String visaCategoryCode;

  const PrerequisiteCheckerScreen({
    super.key,
    required this.visaCategoryCode,
  });

  @override
  ConsumerState<PrerequisiteCheckerScreen> createState() => _PrerequisiteCheckerScreenState();
}

class _PrerequisiteCheckerScreenState extends ConsumerState<PrerequisiteCheckerScreen> {
  final Map<String, bool> _documentStatus = {};
  final Map<String, Map<String, dynamic>> _extractedData = {};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    final prerequisitesAsync = ref.watch(prerequisiteFormsProvider(widget.visaCategoryCode));
    final categoryAsync = ref.watch(visaCategoryByCodeProvider(widget.visaCategoryCode));

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(l10n.documentChecklist),
        centerTitle: true,
        backgroundColor: AppTheme.navyPrimary,
        foregroundColor: AppTheme.inkInverse,
      ),
      body: prerequisitesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (prerequisites) {
          if (prerequisites.isEmpty) {
            return _buildNoPrerequisitesView(context, l10n);
          }

          return Column(
            children: [
              // Header with progress
              categoryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (category) => _buildHeader(context, category, prerequisites, l10n),
              ),

              // List of prerequisites
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: prerequisites.length,
                  itemBuilder: (context, index) {
                    final form = prerequisites[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DocumentCheckCard(
                        form: form,
                        validation: null, // Would come from provider
                        onHasDocumentChanged: (hasDoc) {
                          setState(() {
                            _documentStatus[form.id] = hasDoc;
                          });
                        },
                        onDataExtracted: (data) {
                          setState(() {
                            _extractedData[form.id] = data;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: prerequisitesAsync.when(
        loading: () => null,
        error: (_, __) => null,
        data: (prerequisites) => prerequisites.isEmpty 
            ? null  // No mostrar bottom bar si no hay prerrequisitos (el botón ya está en el body)
            : _buildBottomBar(context, prerequisites, l10n),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    VisaCategory? category,
    List<PrerequisiteForm> prerequisites,
    dynamic l10n,
  ) {
    final completedCount = _documentStatus.values.where((v) => v).length;
    final totalRequired = prerequisites.where((p) => p.isMandatory).length;
    final progress = totalRequired > 0 ? completedCount / totalRequired : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navyPrimary,
        borderRadius: AppTheme.cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyPrimary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.inkInverse.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: AppTheme.inkInverse,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category != null
                          ? '${category.code} - ${VisaLocalization.getVisaName(category.code, category.name, l10n)}'
                          : widget.visaCategoryCode,
                      style: AppTheme.h2WhiteBold,
                    ),
                    if (category != null)
                      Text(
                        'Form: ${category.formEngine.value}',
                        style: AppTheme.bodyWhiteRegular.copyWith(
                          color: AppTheme.inkInverse70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress bar
          Row(
            children: [
              Text(
                l10n.progress,
                style: AppTheme.captionWhiteRegular,
              ),
              const Spacer(),
              Text(
                '$completedCount / $totalRequired ${l10n.required}',
                style: AppTheme.captionWhiteBold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: AppTheme.smallRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.inkInverse24,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppTheme.successGreen : AppTheme.inkInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPrerequisitesView(BuildContext context, dynamic l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppTheme.successGreen,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noPrerequisities,
              style: AppTheme.h1NavyBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noPrerequisitiesDesc,
              textAlign: TextAlign.center,
              style: AppTheme.labelRegular,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/identity/start'),
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.continueToApp),
                 style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: AppTheme.inkInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.inputRadius,
                  ),
                  textStyle: AppTheme.h2WhiteBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, List<PrerequisiteForm> prerequisites, dynamic l10n) {
    final mandatoryForms = prerequisites.where((p) => p.isMandatory).toList();
    final allMandatoryComplete = mandatoryForms.every(
      (form) => _documentStatus[form.id] == true,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.inkInverse,
        boxShadow: [
          BoxShadow(
            color: AppTheme.inkPrimary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: allMandatoryComplete
                    ? AppTheme.successGreen.withOpacity(0.1)
                    : AppTheme.warningOrange.withOpacity(0.1),
                borderRadius: AppTheme.buttonRadius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allMandatoryComplete
                        ? Icons.check_circle
                        : Icons.pending,
                    size: 18,
                    color: allMandatoryComplete ? AppTheme.successGreen : AppTheme.warningOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allMandatoryComplete
                        ? l10n.prerequisitesVerified
                        : l10n.missingDocuments,
                    style: AppTheme.captionNavyBold.copyWith(
                      color: allMandatoryComplete ? AppTheme.successGreen : AppTheme.warningOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: allMandatoryComplete ? () {
                    _continueToApplication(context, l10n);
                } : null,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.continueToApp),
                 style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: AppTheme.inkInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.inputRadius,
                  ),
                  textStyle: AppTheme.h2WhiteBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continueToApplication(BuildContext context, dynamic l10n) {
    // Navigate to DS-160 or DS-260 form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.proceedingToApp),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
