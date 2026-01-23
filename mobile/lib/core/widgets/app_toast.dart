import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

class AppToast {
  static void show(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
    // Dismiss current SnackBar if any
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final Color bgColor = isError 
        ? AppTheme.navyPrimary // Critical error = Navy in V2
        : isSuccess 
            ? AppTheme.navyPrimary 
            : AppTheme.navyPrimary;

    final IconData icon = isError 
        ? Icons.error_outline 
        : isSuccess 
            ? Icons.check_circle_outline 
            : Icons.info_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTheme.h2WhiteBold,
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white.withValues(alpha: 0.8),
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
