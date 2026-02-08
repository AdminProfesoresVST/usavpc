import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/utils/visa_localization.dart';

import 'package:mobile/models/visa_category.dart';

import 'package:mobile/models/prerequisite_form.dart';
import 'package:mobile/providers/visa_providers.dart';
import 'package:mobile/widgets/document_check_card.dart';

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
  bool _autoSkipTriggered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    final prerequisitesAsync = ref.watch(prerequisiteFormsProvider(widget.visaCategoryCode));
    final categoryAsync = ref.watch(visaCategoryByCodeProvider(widget.visaCategoryCode));

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeader(
        title: l10n.documentChecklist,
      ),
      body: prerequisitesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.error(e.toString()))),
        data: (prerequisites) {
          if (prerequisites.isEmpty) {
            // "Pasos Estúpidos" Fix: Auto-skip if empty
               if (categoryAsync.isLoading) {
                 return const Center(child: CircularProgressIndicator(color: AppTheme.navyPrimary));
               }

               if (!_autoSkipTriggered && categoryAsync.hasValue) {
                 _autoSkipTriggered = true;
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                   if(mounted) _continueToApplication(context, l10n);
                 });
               }
            return const Center(child: CircularProgressIndicator(color: AppTheme.navyPrimary));
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
                  padding: EdgeInsets.only(bottom: 100),
                  itemCount: prerequisites.length,
                  itemBuilder: (context, index) {
                    final form = prerequisites[index];
                    return Padding(
                      padding: AppTheme.paddingHorizontal,
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
      margin: AppTheme.paddingEstandar,
      padding: AppTheme.paddingMedio,
      decoration: BoxDecoration(
        color: AppTheme.navyPrimary,
        borderRadius: AppTheme.cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyPrimary.withValues(alpha: 0.3),
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
                padding: AppTheme.paddingPequeno,
                decoration: BoxDecoration(
                  color: AppTheme.inkInverse.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: AppTheme.inkInverse,
                  size: AppTheme.iconoNavegacion,
                ),
              ),
              const SizedBox(width: AppTheme.paddingTarjetas),
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
                          '${l10n.formLabel}: ${category.formEngine.value}',
                          style: AppTheme.bodyWhiteRegular.copyWith(
                          color: AppTheme.inkInverse70,
                          fontSize: AppTheme.fuenteLabel,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.espacioEntreCards),
          
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
          SizedBox(height: AppTheme.espacioEntreCampos),
          ClipRRect(
            borderRadius: AppTheme.smallRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: AppTheme.espacioEntreCampos,
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




  Widget _buildBottomBar(BuildContext context, List<PrerequisiteForm> prerequisites, dynamic l10n) {
    final mandatoryForms = prerequisites.where((p) => p.isMandatory).toList();
    final allMandatoryComplete = mandatoryForms.every(
      (form) => _documentStatus[form.id] == true,
    );

    return Container(
      padding: AppTheme.paddingEstandar,
      decoration: BoxDecoration(
        color: AppTheme.inkInverse,
        boxShadow: [
          BoxShadow(
            color: AppTheme.inkPrimary.withValues(alpha: 0.1),
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
              padding: AppTheme.paddingCampo,
              decoration: BoxDecoration(
                color: allMandatoryComplete
                    ? AppTheme.successGreen.withValues(alpha: 0.1)
                    : AppTheme.warningOrange.withValues(alpha: 0.1),
                borderRadius: AppTheme.buttonRadius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allMandatoryComplete
                        ? Icons.check_circle
                        : Icons.pending,
                    size: AppTheme.iconoMini,
                    color: allMandatoryComplete ? AppTheme.successGreen : AppTheme.warningOrange,
                  ),
                  const SizedBox(width: AppTheme.espacioEntreLabelInput),
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
            SizedBox(height: AppTheme.espacioEntreGrupos),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              height: AppTheme.alturaBotonGrande,
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
    // Determine target form based on category
    final categoryAsync = ref.read(visaCategoryByCodeProvider(widget.visaCategoryCode));
    
    categoryAsync.whenData((category) {
      if (category == null) return;
      final formType = category.formEngine.value; // 'ds160' or 'ds260'
      final visaType = category.code;
      
      // Navigate to Identity Verification, passing context
      context.push(
        Uri(
          path: '/identity/start',
          queryParameters: {
            'type': visaType,
            'form': formType,
          },
        ).toString(),
      );
    });
  }
}
