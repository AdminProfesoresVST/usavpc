import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Standard card used for Service Selection, Visa Categories, etc.
/// Uses white background, shadow, and navy accents.
class StandardServiceCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final IconData? icon;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeBg;
  final Widget? trailing;
  final Widget? customBadge;

  const StandardServiceCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.icon,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
    this.badgeBg,
    this.trailing,
    this.customBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.standardCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.cardRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Compact padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
              children: [
                // Icon Circle (if provided)
                if (icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.navyPrimary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppTheme.navyPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                ],

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTheme.h2NavyBold.copyWith(fontSize: 13),
                            ),
                          ),
                          if (badgeText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsetsDirectional.only(start: 8),
                              decoration: BoxDecoration(
                                color: badgeBg ?? AppTheme.softBlue,
                                borderRadius: AppTheme.smallRadius,
                              ),
                              child: Text(
                                badgeText!,
                                style: AppTheme.labelBold.copyWith(
                                  color: badgeColor ?? AppTheme.navyPrimary,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          if (customBadge != null)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 8),
                              child: customBadge!,
                            ),
                        ],
                      ),
                      if (subtitle != null) ...[
                         const SizedBox(height: 2),
                         Text(
                          subtitle!,
                          style: AppTheme.captionGreyRegular.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: AppTheme.captionGreyRegular.copyWith(fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow or Trailing
                if (trailing != null)
                  trailing!
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Icon(Icons.chevron_right, color: AppTheme.inkSecondary, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
