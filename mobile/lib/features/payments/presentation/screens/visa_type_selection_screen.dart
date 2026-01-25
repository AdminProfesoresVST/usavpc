import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';

/// Visa type selection screen with full i18n support.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class VisaTypeSelectionScreen extends ConsumerWidget {
  const VisaTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeader(title: l10n.visaTypeLabel),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Elegant Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              l10n.eligibilitySubtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppTheme.inkSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),

          // Option 1: Turismo (B1/B2)
          _CompactVisaTile(
            title: l10n.visaB1B2,
            description: l10n.newVisaSubtitle,
            icon: Icons.beach_access_outlined,
            onTap: () => context.push('/identity/start'),
          ),
          
          const SizedBox(height: 12),

          // Option 2: Trabajo
          _CompactVisaTile(
            title: l10n.visaH2,
            description: l10n.interviewSimulatorSubtitle,
            icon: Icons.work_outline,
            onTap: () => context.push('/identity/start?type=h2'),
          ),

          const SizedBox(height: 12),

          // Option 3: Estudiante
          _CompactVisaTile(
            title: l10n.visaF1,
            description: l10n.documentAuditSubtitle,
            icon: Icons.school_outlined,
            onTap: () => context.push('/identity/start?type=f1'),
          ),
        ],
      ),
    );
  }
}

class _CompactVisaTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _CompactVisaTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inkInverse,
        borderRadius: AppTheme.buttonRadius,
        border: Border.all(color: AppTheme.cardBorderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.buttonRadius,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppTheme.navyPrimary, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: AppTheme.navyPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppTheme.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 2),
                  child: Icon(Icons.chevron_right, color: AppTheme.inkSecondary, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
