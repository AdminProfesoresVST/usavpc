import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

import '../../data/models/country_restriction.dart';

/// Widget de alerta de restricción de viaje
class TravelBanWarningCard extends StatelessWidget {
  final RestrictionCheckResult result;
  final VoidCallback? onDismiss;
  final VoidCallback? onLearnMore;

  const TravelBanWarningCard({
    super.key,
    required this.result,
    this.onDismiss,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    if (result.canProceed) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final (backgroundColor, iconColor, icon) = switch (result.level) {
      RestrictionLevel.totalBan => (
        colorScheme.errorContainer,
        colorScheme.error,
        Icons.block_rounded,
      ),
      RestrictionLevel.partialRestriction => (
        AppTheme.warningOrangeLight,
        AppTheme.warningOrange,
        Icons.warning_amber_rounded,
      ),
      RestrictionLevel.immigrantPause => (
        AppTheme.warningOrangeLight,
        AppTheme.warningOrange,
        Icons.pause_circle_outline_rounded,
      ),
      RestrictionLevel.none => (
        colorScheme.tertiaryContainer,
        colorScheme.tertiary,
        Icons.check_circle_outline_rounded,
      ),
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppTheme.cardRadius,
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.2),
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
              color: iconColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLevelTitle(result.level),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (result.countryName != null)
                        Text(
                          result.countryName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: iconColor.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: iconColor.withOpacity(0.5),
                    onPressed: onDismiss,
                  ),
              ],
            ),
          ),
          
          // Message
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              result.message ?? 'Visa processing is currently restricted.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: iconColor.withOpacity(0.9),
              ),
            ),
          ),
          
          // Blocked categories if applicable
          if (result.blockedCategories != null && result.blockedCategories!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.blockedCategories!.map((cat) {
                  return Chip(
                    label: Text(cat),
                    backgroundColor: iconColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: iconColor, fontSize: 12),
                    side: BorderSide(color: iconColor.withOpacity(0.3)),
                  );
                }).toList(),
              ),
            ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onLearnMore != null)
                  TextButton.icon(
                    onPressed: onLearnMore,
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Learn More'),
                    style: TextButton.styleFrom(
                      foregroundColor: iconColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelTitle(RestrictionLevel level) {
    switch (level) {
      case RestrictionLevel.totalBan:
        return 'Entry Prohibited';
      case RestrictionLevel.partialRestriction:
        return 'Visa Category Suspended';
      case RestrictionLevel.immigrantPause:
        return 'Immigrant Processing Paused';
      case RestrictionLevel.none:
        return 'No Restrictions';
    }
  }
}

/// Widget compacto para mostrar estado de restricción
class RestrictionStatusBadge extends StatelessWidget {
  final RestrictionLevel level;
  final bool showLabel;

  const RestrictionStatusBadge({
    super.key,
    required this.level,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final (color, icon, label) = switch (level) {
      RestrictionLevel.totalBan => (
        AppTheme.errorRed,
        Icons.block,
        'Banned',
      ),
      RestrictionLevel.partialRestriction => (
        AppTheme.warningOrange,
        Icons.warning_amber,
        'Restricted',
      ),
      RestrictionLevel.immigrantPause => (
        AppTheme.warningOrange,
        Icons.pause_circle,
        'Paused',
      ),
      RestrictionLevel.none => (
        AppTheme.successGreen,
        Icons.check_circle,
        'Allowed',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppTheme.badgeRadius,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
