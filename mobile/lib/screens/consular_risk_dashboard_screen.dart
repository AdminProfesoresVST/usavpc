import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/models/consular_risk_state.dart';
import 'package:mobile/providers/consular_risk_provider.dart';

/// Consular Risk Real-Time Dashboard
/// SOC-style (Security Operations Center) forensic interface.
/// Implements consular-singularity-engine skill requirements.
class ConsularRiskDashboardScreen extends ConsumerStatefulWidget {
  const ConsularRiskDashboardScreen({super.key});

  @override
  ConsumerState<ConsularRiskDashboardScreen> createState() => _ConsularRiskDashboardScreenState();
}

class _ConsularRiskDashboardScreenState extends ConsumerState<ConsularRiskDashboardScreen> {
  List<String>? _simulationQuestions;
  bool _isSimulating = false;

  @override
  Widget build(BuildContext context) {
    final riskState = ref.watch(consularRiskProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14), // Deep SOC Black
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: _getRiskColor(riskState.riskCategory), size: 20),
            const SizedBox(width: 8),
            const Text(
              'RISK COMMAND',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: riskState.isAnalyzing
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF00D4FF)),
                  SizedBox(height: 16),
                  Text(
                    'ANALYZING PROFILE...',
                    style: TextStyle(
                      color: Color(0xFF00D4FF),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === PROBABILITY GAUGE ===
                  _buildProbabilityGauge(riskState),
                  const SizedBox(height: 24),
                  
                  // === RADAR CHART - FRICTION MAP ===
                  _buildFrictionMapCard(riskState.frictionMap),
                  const SizedBox(height: 24),
                  
                  // === RED FLAG FEED ===
                  _buildRedFlagFeed(riskState.redFlags),
                  const SizedBox(height: 24),
                  
                  // === SENTENCE SIMULATOR ===
                  _buildSentenceSimulator(),
                  
                  if (_simulationQuestions != null) ...[
                    const SizedBox(height: 16),
                    _buildSimulationResults(),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProbabilityGauge(ConsularRiskState state) {
    final probability = state.visaApprovalProbability;
    final category = state.riskCategory;
    final color = _getRiskColor(category);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(
            'VISA APPROVAL PROBABILITY',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: probability,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(probability * 100).toInt()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.label,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            category.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrictionMapCard(FrictionMapData frictionMap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: Colors.white.withOpacity(0.6), size: 18),
              const SizedBox(width: 8),
              Text(
                'FRICTION MAP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: CustomPaint(
              size: const Size(double.infinity, 220),
              painter: RadarChartPainter(frictionMap),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: List.generate(5, (i) {
              final labels = FrictionMapData.axisLabels;
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
        ? const Color(0xFF00C853) 
        : value > 0.3 
            ? const Color(0xFFFFAB00) 
            : const Color(0xFFFF5252);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ${(value * 100).toInt()}%',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRedFlagFeed(List<RedFlagAlert> redFlags) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: redFlags.isEmpty ? Colors.white.withOpacity(0.6) : const Color(0xFFFF5252),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'RED FLAG FEED',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: redFlags.isEmpty 
                        ? const Color(0xFF00C853).withOpacity(0.2)
                        : const Color(0xFFFF5252).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    redFlags.isEmpty ? 'CLEAR' : '${redFlags.length} ALERTS',
                    style: TextStyle(
                      color: redFlags.isEmpty ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (redFlags.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'No red flags detected in current profile.',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: redFlags.length,
              separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
              itemBuilder: (context, index) => _buildRedFlagItem(redFlags[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildRedFlagItem(RedFlagAlert alert) {
    final isCritical = alert.severity == RedFlagSeverity.critical;
    final color = isCritical ? const Color(0xFFFF5252) : const Color(0xFFFFAB00);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCritical ? Icons.error : Icons.warning,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[ALERT] ${alert.title}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceSimulator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Color(0xFF00D4FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'ADVERSARIAL SIMULATION',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Run a 3-question stress test based on detected vulnerabilities.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSimulating ? null : _runSimulation,
              icon: _isSimulating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow, size: 18),
              label: Text(_isSimulating ? 'SIMULATING...' : 'START INTERROGATION'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: const Color(0xFF0A0E14),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.question_answer, color: Color(0xFF00D4FF), size: 16),
              const SizedBox(width: 8),
              Text(
                'SIMULATED QUESTIONS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_simulationQuestions!.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Color(0xFF00D4FF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _simulationQuestions![i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _runSimulation() async {
    setState(() {
      _isSimulating = true;
      _simulationQuestions = null;
    });
    
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    final questions = await ref.read(consularRiskProvider.notifier).runSentenceSimulation();
    
    setState(() {
      _isSimulating = false;
      _simulationQuestions = questions;
    });
  }

  Color _getRiskColor(RiskCategory category) {
    switch (category) {
      case RiskCategory.low:
        return const Color(0xFF00C853); // Green
      case RiskCategory.moderate:
        return const Color(0xFFFFAB00); // Amber
      case RiskCategory.high:
        return const Color(0xFFFF6D00); // Orange
      case RiskCategory.critical:
        return const Color(0xFFFF5252); // Red
    }
  }
}

/// Custom painter for radar chart
class RadarChartPainter extends CustomPainter {
  final FrictionMapData data;
  
  RadarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 30;
    final values = data.toRadarValues();
    const sides = 5;
    
    // Draw grid circles
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 1; i <= 4; i++) {
      final r = radius * (i / 4);
      final path = Path();
      for (int j = 0; j < sides; j++) {
        final angle = (j * 2 * math.pi / sides) - (math.pi / 2);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }
    
    // Draw axis lines
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }
    
    // Draw data polygon
    final dataPath = Path();
    final dataPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final dataStrokePaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final r = radius * values[i];
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, dataStrokePaint);
    
    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final r = radius * values[i];
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
    
    // Draw labels
    final labels = FrictionMapData.axisLabels;
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.7),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final labelRadius = radius + 20;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);
      
      final textSpan = TextSpan(text: labels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
