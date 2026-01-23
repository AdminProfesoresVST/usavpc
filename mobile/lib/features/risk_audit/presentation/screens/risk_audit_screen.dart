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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Score Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.approvalProbability,
                        style: AppTheme.bodyGreyRegular,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${evaluation.score}%',
                          style: AppTheme.h1NavyBold.copyWith(
                            color: isHighApproval ? AppTheme.navyPrimary : AppTheme.actionBlue
                          ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.softBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.riskLevel(evaluation.riskLevel),
                            style: AppTheme.smallNavyBold.copyWith(
                              color: isHighApproval ? AppTheme.navyPrimary : AppTheme.actionBlue
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Factors
                Text(l10n.factorAnalysis, style: AppTheme.h2NavyBold),
                const SizedBox(height: 16),
                
                ...evaluation.positiveFactors.map((f) => _buildFactorTile(context, f, true)),
                 if (evaluation.negativeFactors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...evaluation.negativeFactors.map((f) => _buildFactorTile(context, f, false)),
                 ],

                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: () {
                     context.go('/simulator/chat'); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.navyPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(l10n.continueToSimulator, style: AppTheme.bodyWhiteRegular),
                ),
                const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.check_circle : Icons.info_outline,
            color: isPositive ? AppTheme.navyPrimary : AppTheme.actionBlue,
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: context.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
