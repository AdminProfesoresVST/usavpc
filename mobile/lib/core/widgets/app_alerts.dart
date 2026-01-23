import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Standardized Alert System for Design System V2.
/// Replaces generic SnackBars and Toasts.
class AppAlert extends StatelessWidget {
  final String message;
  final AlertType type;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppAlert._({
    required this.message,
    required this.type,
    this.onAction,
    this.actionLabel,
  });

  /// Level 1: Info Alert (Help / Tips)
  /// "Consejos para llenar el formulario"
  factory AppAlert.info({required String message}) {
    return AppAlert._(message: message, type: AlertType.info);
  }

  /// Level 2: Critical Alert (Error / Validation)
  /// "Campos vacíos, error de conxión"
  factory AppAlert.critical({required String message, VoidCallback? onRetry, String? retryText}) {
    return AppAlert._(
      message: message, 
      type: AlertType.critical,
      onAction: onRetry,
      actionLabel: retryText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInfo = type == AlertType.info;
    
    // Config based on Type
    final backgroundColor = isInfo ? AppTheme.softBlue : AppTheme.navyPrimary;
    final textColor = isInfo ? AppTheme.inkPrimary : AppTheme.inkInverse;
    final iconColor = isInfo ? AppTheme.actionBlue : AppTheme.inkInverse;
    final iconData = isInfo ? Icons.info_outline : Icons.warning_amber_rounded;
    
    // Typography
    // Info: Roboto 14px Regular
    // Critical: Roboto 14px Bold
    final textStyle = isInfo 
        ? AppTheme.labelRegular.copyWith(color: textColor)
        : AppTheme.labelBold.copyWith(color: textColor);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        // Info gets a left border
        border: isInfo 
            ? const Border(left: BorderSide(color: AppTheme.actionBlue, width: 4)) 
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: textStyle),
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionLabel!,
                      style: AppTheme.labelBold.copyWith(
                        color: isInfo ? AppTheme.actionBlue : AppTheme.softBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum AlertType { info, critical }
