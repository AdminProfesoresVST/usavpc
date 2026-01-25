import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/risk_audit/logic/risk_evaluator.dart';
import 'package:mobile/features/risk_audit/presentation/providers/application_provider.dart';

/// Risk audit screen with full i18n support.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class RiskAuditScreen extends ConsumerWidget {
  const RiskAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final userAppAsync = ref.watch(userApplicationProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeader(title: l10n.approvalAuditTitle),
      body: userAppAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorLoadingData(e.toString()))),
        data: (userApp) {
          final evaluator = RiskEvaluator();
          final evaluation = evaluator.evaluate(
            visaType: userApp?.visaType ?? 'B1/B2',
            age: userApp?.age,
            nationality: userApp?.formData['nationality'] as String?,
            hasStrongTies: userApp?.hasStrongTies ?? false,
            hasTravelHistory: userApp?.hasTravelHistory ?? false,
          );

          final isHighApproval = evaluation.score > 70;

          return SingleChildScrollView(
            padding: AppTheme.paddingGrande,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score Card
                Container(
                  padding: AppTheme.paddingExtraGrande,
                  decoration: BoxDecoration(
                    color: AppTheme.inkInverse,
                    borderRadius: AppTheme.badgeRadius,
                    boxShadow: [BoxShadow(color: AppTheme.inkPrimary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.approvalProbability,
                        style: AppTheme.labelRegular,
                      ),
                      SizedBox(height: AppTheme.espacioEntreSecciones),
                      Text(
                        '${evaluation.score}%',
                          style: AppTheme.h1NavyBold.copyWith(
                            color: isHighApproval ? AppTheme.navyPrimary : AppTheme.actionBlue
                          ),
                      ),
                      SizedBox(height: AppTheme.espacioEntreCampos),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.softBlue,
                          borderRadius: AppTheme.badgeRadius,
                        ),
                        child: Text(
                          l10n.riskLevel(evaluation.riskLevel),
                            style: AppTheme.captionNavyBold.copyWith(
                              color: isHighApproval ? AppTheme.navyPrimary : AppTheme.actionBlue
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.espacioEntreCards),

                // Factors
                Text(l10n.factorAnalysis, style: AppTheme.h2NavyBold),
                SizedBox(height: AppTheme.espacioEntreSecciones),
                
                ...evaluation.positiveFactors.map((f) => _buildFactorTile(context, f, true)),
                 if (evaluation.negativeFactors.isNotEmpty) ...[
                    SizedBox(height: AppTheme.espacioEntreCampos),
                    ...evaluation.negativeFactors.map((f) => _buildFactorTile(context, f, false)),
                 ],

                SizedBox(height: AppTheme.espacioEntreBloques),
                
                ElevatedButton(
                  onPressed: () {
                     context.go('/simulator/chat'); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                  ),
                  child: Text(l10n.continueToSimulator, style: AppTheme.bodyWhiteRegular),
                ),
                SizedBox(height: AppTheme.espacioEntreGrupos),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(l10n.backToHome),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFactorTile(BuildContext context, String text, bool isPositive) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 12),
      padding: AppTheme.paddingEstandar,
      decoration: BoxDecoration(
        color: AppTheme.inkInverse,
        borderRadius: AppTheme.inputRadius,
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.check_circle : Icons.info_outline,
            color: isPositive ? AppTheme.navyPrimary : AppTheme.actionBlue,
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: AppTheme.bodyPrimaryRegular)),
        ],
      ),
    );
  }
}
