import 'dart:math' as math;
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
                      color: color.withOpacity(0.15),
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
    
    return Container(
      padding: AppTheme.paddingMedio,
      decoration: AppTheme.standardCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: AppTheme.inkSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.frictionMap,
                style: AppTheme.captionGreyBold.copyWith(letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: RadarChartPainter(frictionMap, labels),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(5, (i) {
              final values = frictionMap.toRadarValues();
              return _buildLegendItem(labels[i], values[i]);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double value) {
    final color = value > 0.6 
        ? AppTheme.successGreen
        : value > 0.3 
            ? AppTheme.warningOrange 
            : AppTheme.errorRed;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: ${(value * 100).toInt()}%', style: AppTheme.captionGreyRegular),
      ],
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
    switch (category) {
      case RiskCategory.low: return AppTheme.successGreen;
      case RiskCategory.moderate: return AppTheme.warningOrange;
      case RiskCategory.high: return const Color(0xFFE65100);
      case RiskCategory.critical: return AppTheme.errorRed;
    }
  }
}

/// Custom painter for radar chart using AppTheme colors
class RadarChartPainter extends CustomPainter {
  final FrictionMapData data;
  final List<String> labels;
  
  RadarChartPainter(this.data, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 30;
    final values = data.toRadarValues();
    const sides = 5;
    
    final gridPaint = Paint()
      ..color = AppTheme.dividerGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 1; i <= 4; i++) {
      final r = radius * (i / 4);
      final path = Path();
      for (int j = 0; j < sides; j++) {
        final angle = (j * 2 * math.pi / sides) - (math.pi / 2);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (j == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }
    
    final dataPath = Path();
    final dataPaint = Paint()
      ..color = AppTheme.actionBlue.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    final dataStrokePaint = Paint()
      ..color = AppTheme.actionBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final r = radius * values[i];
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) { dataPath.moveTo(x, y); } else { dataPath.lineTo(x, y); }
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, dataStrokePaint);
    
    final pointPaint = Paint()
      ..color = AppTheme.actionBlue
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final r = radius * values[i];
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
    
    final textStyle = TextStyle(
      color: AppTheme.inkSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final labelRadius = radius + 18;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);
      
      final textSpan = TextSpan(text: labels[i], style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
