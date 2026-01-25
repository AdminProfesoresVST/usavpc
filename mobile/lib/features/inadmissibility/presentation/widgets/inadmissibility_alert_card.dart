import 'package:flutter/material.dart';

import '../../data/models/inadmissibility_flag.dart';

/// Tarjeta de alerta de inadmisibilidad
class InadmissibilityAlertCard extends StatelessWidget {
  final InadmissibilityFlag flag;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onLearnMore;

  const InadmissibilityAlertCard({
    super.key,
    required this.flag,
    this.onAcknowledge,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSeverityColor(flag.severity);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTypeIcon(flag.flagType),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            flag.flagType.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildSeverityBadge(theme, flag.severity, color),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Detected Issue',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (flag.userAcknowledged)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flag.flagType.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                
                if (flag.detectedFromField != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: AppTheme.buttonRadius,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodySmall,
                              children: [
                                const TextSpan(text: 'Detected from: '),
                                TextSpan(
                                  text: _formatFieldName(flag.detectedFromField!),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (flag.detectedValue != null) ...[
                                  const TextSpan(text: ' = '),
                                  TextSpan(
                                    text: flag.detectedValue,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Waiver suggestion
                if (flag.suggestedWaiver != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.blue.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: AppTheme.inputRadius,
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: AppTheme.smallRadius,
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.blue,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Suggested Waiver: ${flag.suggestedWaiver}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        if (flag.waiverNotes != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            flag.waiverNotes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (!flag.userAcknowledged)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onLearnMore != null)
                    TextButton.icon(
                      onPressed: onLearnMore,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Learn More'),
                    ),
                  const SizedBox(width: 8),
                  if (onAcknowledge != null)
                    FilledButton.icon(
                      onPressed: onAcknowledge,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('I Understand'),
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge(ThemeData theme, Severity severity, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: AppTheme.inputRadius,
      ),
      child: Text(
        severity.value.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getSeverityColor(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return Colors.red;
      case Severity.high:
        return Colors.orange;
      case Severity.medium:
        return Colors.amber.shade700;
      case Severity.low:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(InadmissibilityType type) {
    switch (type) {
      case InadmissibilityType.unlawfulPresence:
        return Icons.timer_off;
      case InadmissibilityType.visaOverstay:
        return Icons.calendar_today;
      case InadmissibilityType.criminalRecord:
        return Icons.gavel;
      case InadmissibilityType.immigrationFraud:
        return Icons.dangerous;
      case InadmissibilityType.publicCharge:
        return Icons.attach_money;
      case InadmissibilityType.healthGrounds:
        return Icons.medical_services;
      case InadmissibilityType.returningResident:
        return Icons.home_work;
    }
  }

  String _formatFieldName(String field) {
    return field
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
