import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

import '../../data/models/visa_fee.dart';

/// Widget de desglose de costos
class CostBreakdownCard extends StatelessWidget {
  final CostCalculation calculation;
  final VoidCallback? onSave;

  const CostBreakdownCard({
    super.key,
    required this.calculation,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppTheme.badgeRadius,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with total
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Cost',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: AppTheme.badgeRadius,
                      ),
                      child: Text(
                        calculation.visaCategory,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.espacioEntreCampos),
                Text(
                  '\$${calculation.totalUsd}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.espacioEntreLabelInput),
                Text(
                  'USD',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Fee breakdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...calculation.breakdown.map((item) => _buildFeeRow(
                  context,
                  item,
                )),
                
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: colorScheme.outlineVariant),
                ),
                
                // Subtotals
                _buildSummaryRow(
                  context,
                  'Mandatory Fees',
                  calculation.mandatoryTotal,
                  isBold: true,
                ),
                
                if (calculation.refundableTotal > 0)
                  _buildRefundableRow(context, calculation.refundableTotal),
              ],
            ),
          ),

          // Notes section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Important Notes',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.espacioEntreCampos),
                Text(
                  '• MRV fee is non-refundable once paid\n'
                  '• Integrity Fee may be refunded with proof of timely departure\n'
                  '• SEVIS fee must be paid before interview',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(BuildContext context, CostBreakdownItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon based on fee type
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getFeeColor(item.feeType).withOpacity(0.1),
              borderRadius: AppTheme.buttonRadius,
            ),
            child: Icon(
              _getFeeIcon(item.feeType),
              size: 18,
              color: _getFeeColor(item.feeType),
            ),
          ),
          const SizedBox(width: 12),
          
          // Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.isRefundable) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreenLight,
                          borderRadius: AppTheme.smallRadius,
                        ),
                        child: Text(
                          'Refundable',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.successGreen,
                            fontSize: AppTheme.fuenteCaption,
                          ),
                        ),
                      ),
                    ],
                    if (item.isOptional) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.infoBlueLight,
                          borderRadius: AppTheme.smallRadius,
                        ),
                        child: Text(
                          'Optional',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.infoBlue,
                            fontSize: AppTheme.fuenteCaption,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.notes != null)
                  Text(
                    item.notes!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          
          // Amount
          Text(
            '\$${item.amountUsd}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    int amount, {
    bool isBold = false,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$$amount',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundableRow(BuildContext context, int amount) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successGreenLight,
        borderRadius: AppTheme.buttonRadius,
        border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.replay, size: 18, color: AppTheme.successGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Up to \$$amount may be refundable with timely departure',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.successGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFeeColor(FeeType type) {
    switch (type) {
      case FeeType.mrvBase:
        return AppTheme.infoBlue;
      case FeeType.integrityFee:
        return AppTheme.warningOrange;
      case FeeType.sevisI901:
        return AppTheme.actionBlue;
      case FeeType.i94Land:
        return AppTheme.warningOrange;
      case FeeType.reciprocity:
        return AppTheme.navyPrimary;
      case FeeType.premiumProcessing:
        return AppTheme.warningOrange;
      case FeeType.biometrics:
        return AppTheme.actionBlue;
    }
  }

  IconData _getFeeIcon(FeeType type) {
    switch (type) {
      case FeeType.mrvBase:
        return Icons.receipt_long;
      case FeeType.integrityFee:
        return Icons.verified_user;
      case FeeType.sevisI901:
        return Icons.school;
      case FeeType.i94Land:
        return Icons.directions_car;
      case FeeType.reciprocity:
        return Icons.swap_horiz;
      case FeeType.premiumProcessing:
        return Icons.speed;
      case FeeType.biometrics:
        return Icons.fingerprint;
    }
  }
}
