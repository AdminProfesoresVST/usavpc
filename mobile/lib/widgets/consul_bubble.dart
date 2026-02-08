import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Consul message bubble widget - elegant, smaller text, left-aligned.
/// Created: 2026-01-23 - Chat bubbles UI redesign
/// Design: Formal, delicate text style to represent official consul speech.
class ConsulBubble extends StatelessWidget {
  final String text;

  const ConsulBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.only(bottom: 16, right: 40),
        padding: AppTheme.paddingCampo,
        decoration: BoxDecoration(
          color: AppTheme.inkInverse, // White background for better contrast
          borderRadius: BorderRadius.only(
            topLeft: AppTheme.radiusPequeno,
            topRight: AppTheme.radiusBurbuja,
            bottomLeft: AppTheme.radiusBurbuja,
            bottomRight: AppTheme.radiusBurbuja,
          ),
          border: Border.all(color: AppTheme.inkPrimary.withValues(alpha: 0.1), width: 1), // Subtle border
          boxShadow: [
             BoxShadow(color: AppTheme.inkPrimary.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          style: AppTheme.bodyPrimaryRegular.copyWith(color: AppTheme.navyPrimary, height: 1.4), // readable height
        ),
      ),
    );
  }
}
