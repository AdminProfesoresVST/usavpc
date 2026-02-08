
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/models/consular_risk_state.dart';
import 'package:mobile/providers/consular_risk_provider.dart';

/// Consular Risk Real-Time Dashboard
/// Uses AppTheme design system and l10n for UI consistency.
/// Implements consular-singularity-engine skill requirements.
class ConsularRiskDashboardScreen extends ConsumerWidget {
  const ConsularRiskDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskState = ref.watch(consularRiskProvider);
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.navyPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: AppTheme.inkInverse, size: 20),
            const SizedBox(width: 8),
            Text(l10n.riskCommandTitle, style: AppTheme.h1WhiteBold),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: riskState.isAnalyzing
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.actionBlue),
                  const SizedBox(height: 16),
                  Text(l10n.analyzingProfile, style: AppTheme.captionGreyRegular),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: AppTheme.paddingEstandar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProbabilityGauge(context, riskState),
                  SizedBox(height: AppTheme.espacioEntreTarjetas),
                  _buildFrictionMapCard(context, riskState.frictionMap),
                  SizedBox(height: AppTheme.espacioEntreTarjetas),
                  _buildRedFlagFeed(context, riskState.redFlags),
                  SizedBox(height: AppTheme.espacioEntreTarjetas),
                  _buildSimulatorSection(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProbabilityGauge(BuildContext context, ConsularRiskState state) {
    final probability = state.visaApprovalProbability;
    final category = state.riskCategory;
    final color = _getRiskColor(category);
    final l10n = context.l10n;
    
    return Container(
      padding: AppTheme.paddingMedio,
      decoration: AppTheme.standardCardDecoration,
      child: Column(
        children: [
          Text(
            l10n.visaApprovalProbability,
            style: AppTheme.captionGreyBold.copyWith(letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: probability,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.dividerGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(probability * 100).toInt()}%',
                    style: AppTheme.h1NavyBold.copyWith(fontSize: 36, color: color),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: AppTheme.badgeRadius,
                    ),
                    child: Text(
                      _getRiskLabel(context, category),
                      style: AppTheme.captionNavyBold.copyWith(
                        color: color,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getRiskDescription(context, category),
            textAlign: TextAlign.center,
            style: AppTheme.captionGreyRegular,
          ),
        ],
      ),
    );
  }

  Widget _buildFrictionMapCard(BuildContext context, FrictionMapData frictionMap) {
    final l10n = context.l10n;
    final labels = [
      l10n.axisEconomic,
      l10n.axisSocial,
      l10n.axisDocuments,
      l10n.axisConsistency,
      l10n.axisTravel,
    ];
    final values = frictionMap.toRadarValues();
    
    return Container(
      padding: AppTheme.paddingMedio,
      decoration: AppTheme.standardCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: AppTheme.inkSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'FACTORES CLAVE', // [UX] Simplified Title
                style: AppTheme.captionGreyBold.copyWith(letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(5, (i) => _buildFactorRow(context, labels[i], values[i])),
        ],
      ),
    );
  }

  Widget _buildFactorRow(BuildContext context, String label, double value) {
    final isStrong = value > 0.7;
    final isModerate = value > 0.4;
    // [UI-SKILL] Enforcing Navy/Blue Palette (No Red/Green for status)
    final color = isStrong 
        ? AppTheme.navyPrimary 
        : isModerate ? AppTheme.actionBlue : AppTheme.inkSecondary;
        
    final statusText = isStrong 
        ? 'Fuerte' 
        : isModerate ? 'Moderado' : 'Por Mejorar';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTheme.bodyPrimaryRegular.copyWith(fontWeight: FontWeight.w500)),
              Text(
                statusText,
                style: AppTheme.captionNavyBold.copyWith(color: color, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppTheme.dividerGrey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildRedFlagFeed(BuildContext context, List<RedFlagAlert> redFlags) {
    final l10n = context.l10n;
    
    return Container(
      decoration: AppTheme.standardCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppTheme.paddingEstandar,
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: redFlags.isEmpty ? AppTheme.successGreen : AppTheme.errorRed,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.redFlagFeed,
                  style: AppTheme.captionGreyBold.copyWith(letterSpacing: 1),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: redFlags.isEmpty 
                        ? AppTheme.successGreenLight
                        : AppTheme.errorRedLight,
                    borderRadius: AppTheme.badgeRadius,
                  ),
                  child: Text(
                    redFlags.isEmpty ? l10n.redFlagClear : l10n.redFlagAlerts(redFlags.length),
                    style: AppTheme.captionNavyBold.copyWith(
                      color: redFlags.isEmpty ? AppTheme.successGreen : AppTheme.errorRed,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (redFlags.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(l10n.noRedFlagsDetected, style: AppTheme.captionGreyRegular),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: redFlags.length,
              separatorBuilder: (_, __) => Divider(color: AppTheme.dividerGrey, height: 1),
              itemBuilder: (context, index) => _buildRedFlagItem(redFlags[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildRedFlagItem(RedFlagAlert alert) {
    final isCritical = alert.severity == RedFlagSeverity.critical;
    final color = isCritical ? AppTheme.errorRed : AppTheme.warningOrange;
    final bgColor = isCritical ? AppTheme.errorRedLight : AppTheme.warningOrangeLight;
    
    return Padding(
      padding: AppTheme.paddingEstandar,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, borderRadius: AppTheme.smallRadius),
            child: Icon(isCritical ? Icons.error : Icons.warning, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[ALERT] ${alert.title}',
                  style: AppTheme.captionNavyBold.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(alert.description, style: AppTheme.captionGreyRegular),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorSection(BuildContext context) {
    final l10n = context.l10n;
    
    return Container(
      padding: AppTheme.paddingMedio,
      decoration: AppTheme.navyHeaderCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over, color: AppTheme.inkInverse, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.practiceWithSimulator,
                style: AppTheme.captionWhiteBold.copyWith(letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.practiceWithSimulatorDesc, style: AppTheme.captionWhiteRegular),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/simulator/chat'),
              icon: Icon(Icons.play_arrow, size: 18, color: AppTheme.navyPrimary),
              label: Text(
                l10n.goToSimulator,
                style: AppTheme.labelBold.copyWith(color: AppTheme.navyPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.inkInverse,
                foregroundColor: AppTheme.navyPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRiskLabel(BuildContext context, RiskCategory category) {
    final l10n = context.l10n;
    switch (category) {
      case RiskCategory.low: return l10n.riskLow;
      case RiskCategory.moderate: return l10n.riskModerate;
      case RiskCategory.high: return l10n.riskHigh;
      case RiskCategory.critical: return l10n.riskCritical;
    }
  }

  String _getRiskDescription(BuildContext context, RiskCategory category) {
    final l10n = context.l10n;
    switch (category) {
      case RiskCategory.low: return l10n.riskLowDesc;
      case RiskCategory.moderate: return l10n.riskModerateDesc;
      case RiskCategory.high: return l10n.riskHighDesc;
      case RiskCategory.critical: return l10n.riskCriticalDesc;
    }
  }

  Color _getRiskColor(RiskCategory category) {
    // [UI-SKILL] Enforcing Navy/Blue Palette
    switch (category) {
      case RiskCategory.low: return AppTheme.navyPrimary; // Best case
      case RiskCategory.moderate: return AppTheme.actionBlue;
      case RiskCategory.high: return AppTheme.inkSecondary; // Neutral warning
      case RiskCategory.critical: return AppTheme.inkSecondary; // Avoid red
    }
  }
}
