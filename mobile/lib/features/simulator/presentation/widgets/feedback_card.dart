import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/kyc/data/simulator_models.dart';

class FeedbackCard extends StatelessWidget {
  final SimulatorFeedback feedback;

  const FeedbackCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    // Color Logic
    Color cardColor;
    IconData icon;
    String title;

    switch (feedback.score.toLowerCase()) {
      case 'good':
      case 'buena':
        cardColor = AppTheme.softBlue; // Was Green.shade50
        icon = Icons.check_circle;
        title = "Good Answer";
        break;
      case 'bad':
      case 'mala':
        cardColor = AppTheme.inkSecondary; // Was Red.shade50
        icon = Icons.cancel;
        title = "Needs Improvement";
        break;
      default: // ok, regular
        cardColor = AppTheme.inkInverse; // Was Amber.shade50
        icon = Icons.info;
        title = "Acceptable";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: AppTheme.inputRadius,
        border: Border.all(
          color: AppTheme.navyPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, 
                color: AppTheme.navyPrimary, // Strict Navy
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppTheme.captionNavyBold.copyWith(
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Text(
            feedback.critique,
            style: AppTheme.labelRegular.copyWith(fontWeight: FontWeight.w500),
          ),
          if (feedback.recommendation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.inkInverse.withOpacity(0.6),
                borderRadius: AppTheme.smallRadius,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, size: 16, color: AppTheme.actionBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feedback.recommendation,
                      style: AppTheme.captionGreyRegular.copyWith(color: AppTheme.actionBlue, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
