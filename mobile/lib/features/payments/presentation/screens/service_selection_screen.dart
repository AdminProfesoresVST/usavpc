import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

/// Main service selection screen (landing page) with full i18n support.
/// Updated: 2026-01-21 - Applied i18n per audit requirements
/// NOTE: This is the MAIN PAGE - keeps unique design with SliverAppBar
class ServiceSelectionScreen extends ConsumerWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: CustomScrollView(
        slivers: [
          // 1. Navy Navbar
          SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.navyPrimary,
            title: Row(
              children: [
                const Icon(Icons.policy, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.appTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Hero Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.navyPrimary,
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      opacity: 0.1,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              l10n.officialGuide,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.heroTitle,
                        style: context.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.heroSubtitle,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // 3. How it Works (Steps)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 0),
                  child: Text(
                    l10n.howItWorks,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppTheme.navyPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StepItem(icon: Icons.document_scanner, title: l10n.stepScan, subtitle: l10n.stepScanSubtitle, isFirst: true),
                      const SizedBox(width: 12),
                      _StepItem(icon: Icons.chat, title: l10n.stepSimulate, subtitle: l10n.stepSimulateSubtitle),
                      const SizedBox(width: 12),
                      _StepItem(icon: Icons.assignment_turned_in, title: l10n.stepResults, subtitle: l10n.stepResultsSubtitle, isLast: true),
                    ],
                  ),
                ),

                // 4. Popular Services
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 32, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.popularServices,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: AppTheme.navyPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.viewAll,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppTheme.navyPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Card 1: New Application
                      _ServiceCard(
                        title: l10n.newVisaApplication,
                        subtitle: l10n.newVisaSubtitle,
                        icon: Icons.contact_page,
                        badgeText: l10n.badgeFast,
                        badgeColor: Colors.green.shade700,
                        badgeBg: Colors.green.shade50,
                        onTap: () => _handleNavigation(context, ref, '/visa-type'),
                      ),
                      
                      const SizedBox(height: 12),

                      // Card 2: Simulator
                      _ServiceCard(
                        title: l10n.interviewSimulator,
                        subtitle: l10n.interviewSimulatorSubtitle,
                        icon: Icons.forum,
                        badgeBg: Colors.blue.shade50,
                        onTap: () => _handleNavigation(context, ref, '/quick-check'),
                      ),

                      const SizedBox(height: 12),

                      // Card 3: Audit (Checklist)
                      _ServiceCard(
                        title: l10n.documentAudit,
                        subtitle: l10n.documentAuditSubtitle,
                        icon: Icons.checklist,
                        onTap: () => _handleNavigation(context, ref, '/quick-check'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 5. Trust Signal
                Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.green.shade700),
                        const SizedBox(width: 6),
                        Text(
                          l10n.securityNote,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(BuildContext context, WidgetRef ref, String targetRoute) {
      final isLoggedIn = ref.read(authStateProvider).value != null;
      if (isLoggedIn) {
        GoRouter.of(context).push(targetRoute);
      } else {
        GoRouter.of(context).push('/login');
      }
  }
}

// --- Helper Widgets ---

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;

  const _StepItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.navyPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.navyPrimary, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.navyPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: context.textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeBg;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
    this.badgeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.navyPrimary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.navyPrimary, size: 24),
                ),
                const SizedBox(width: 16),
                
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
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.navyPrimary,
                              ),
                            ),
                          ),
                          if (badgeText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsetsDirectional.only(start: 8),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badgeText!,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
