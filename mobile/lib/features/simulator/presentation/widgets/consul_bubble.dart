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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.inkSecondary,
          borderRadius: BorderRadius.only(
            topLeft: AppTheme.radiusPequeno,
            topRight: AppTheme.radiusBurbuja,
            bottomLeft: AppTheme.radiusBurbuja,
            bottomRight: AppTheme.radiusBurbuja,
          ),
          border: Border.all(color: AppTheme.inkSecondary, width: 1),
        ),
        child: Text(
          text,
          style: AppTheme.bodyPrimaryRegular.copyWith(color: AppTheme.navyPrimary),
        ),
      ),
    );
  }
}
