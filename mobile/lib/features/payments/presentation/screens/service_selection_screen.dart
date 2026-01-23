import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/widgets/app_toast.dart';

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
                  style: AppTheme.h1WhiteBold,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Reduced from 24
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Compact badge
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              l10n.officialGuide,
                              style: AppTheme.smallWhiteBold.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12), // Reduced from 16
                      Text(
                        l10n.heroTitle,
                        style: AppTheme.h1WhiteBold.copyWith(fontSize: 20), // Reduced header size
                      ),
                      const SizedBox(height: 4), // Reduced from 8
                      Text(
                        l10n.heroSubtitle,
                        style: AppTheme.bodyWhiteRegular.copyWith(color: Colors.white70, fontSize: 13),
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16), // Reduced from 24
                    ],
                  ),
                ),

                // 3. How it Works (Steps)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0), // Reduced top from 24
                  child: Text(
                    l10n.howItWorks,
                    style: AppTheme.h2NavyBold.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12), // Reduced from 16
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StepItem(icon: Icons.document_scanner, title: l10n.stepScan, subtitle: l10n.stepScanSubtitle, isFirst: true),
                      const SizedBox(width: 8), // Reduced gap
                      _StepItem(icon: Icons.chat, title: l10n.stepSimulate, subtitle: l10n.stepSimulateSubtitle),
                      const SizedBox(width: 8),
                      _StepItem(icon: Icons.assignment_turned_in, title: l10n.stepResults, subtitle: l10n.stepResultsSubtitle, isLast: true),
                    ],
                  ),
                ),

                // 4. Popular Services
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 8), // Much tighter spacing
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.popularServices,
                        style: AppTheme.h2NavyBold.copyWith(fontSize: 16),
                      ),
                      Text(
                        l10n.viewAll,
                        style: AppTheme.smallNavyBold.copyWith(fontSize: 12),
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
                        badgeColor: AppTheme.navyPrimary,
                        badgeBg: AppTheme.softBlue,
                        onTap: () => _handleNavigation(context, ref, '/visa-type'),
                      ),
                      
                      const SizedBox(height: 8), // Reduced from 12

                      // Card 2: Simulator
                      _ServiceCard(
                        title: l10n.interviewSimulator,
                        subtitle: l10n.interviewSimulatorSubtitle,
                        icon: Icons.forum,
                        badgeBg: AppTheme.softBlue,
                        onTap: () => _handleSimulatorTap(context, ref),
                      ),

                      const SizedBox(height: 8),

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

                const SizedBox(height: 16), // Reduced from 40

                // 5. Trust Signal
                Center(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: 16), // Reduced from 30
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 12, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          l10n.securityNote,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
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

  Future<void> _handleSimulatorTap(BuildContext context, WidgetRef ref) async {
    final isLoggedIn = ref.read(authStateProvider).value != null;
    final l10n = context.l10n;

    if (!isLoggedIn) {
      GoRouter.of(context).push('/login');
      return;
    }

    // CHECK DATA
    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      
      final app = await supabase
          .from('applications')
          .select('form_data')
          .eq('user_id', userId!)
          .maybeSingle();

      if (app != null && app['form_data'] != null && app['form_data']['ocr_confirmed'] == true) {
        // Data Exists -> Go to Simulator
        if (context.mounted) GoRouter.of(context).push('/simulator/chat');
      } else {
        // No Data -> Go to Verification
        if (context.mounted) {
           AppToast.show(context, l10n.error("Profile incomplete. Please scan passport first.")); // TODO: Add i18n key or use generic
           GoRouter.of(context).push('/identity/start');
        }
      }
    } catch (e) {
       // On error, default to safety (Verification)
       if (context.mounted) GoRouter.of(context).push('/identity/start');
    }
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4), // Reduced padding
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
              width: 32, // Reduced from 40
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.navyPrimary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.navyPrimary, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.navyPrimary,
                fontSize: 11, // Reduced font
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTheme.smallGreyRegular.copyWith(fontSize: 9),
              textAlign: TextAlign.center,
              maxLines: 1,
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
        borderRadius: BorderRadius.circular(10), // Slightly reduced radius
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12), // Reduced from 16
            child: Row(
              children: [
                // Icon Circle
                Container(
                  width: 40, // Reduced from 48
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.navyPrimary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.navyPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                
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
                              style: AppTheme.h3NavySemiBold.copyWith(fontSize: 13), // Reduced font
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
                                style: AppTheme.labelBold.copyWith(
                                  color: badgeColor,
                                  fontSize: 8, // Very small badge
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTheme.smallGreyRegular.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
