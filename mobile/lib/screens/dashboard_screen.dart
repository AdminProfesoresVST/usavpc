
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/providers/dashboard_provider.dart';
import 'package:mobile/models/dashboard_data.dart';

/// Production-ready dashboard with functional action tiles and full i18n.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Restore the dashboard data provider for the Status Card (Hero)
    final dashboardAsync = ref.watch(dashboardProvider); 

    return Scaffold(
      appBar: AppHeader(
        title: l10n.appTitle,
      ),
      body: dashboardAsync.when(
        data: (data) => SingleChildScrollView(
          padding: AppTheme.paddingEstandar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: const BoxDecoration(
                  color: AppTheme.navyPrimary,
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    opacity: 0.1,
                    alignment: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(24)), // More consistent radius
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.inkInverse.withValues(alpha: 0.15),
                        borderRadius: AppTheme.smallRadius,
                        border: Border.all(color: AppTheme.inkInverse.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user, color: AppTheme.inkInverse, size: AppTheme.iconoPequeno),
                          const SizedBox(width: 4),
                          Text(
                            l10n.officialGuide,
                            style: AppTheme.captionWhiteBold,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppTheme.espacioEntreGrupos),
                    Text(
                      l10n.heroTitle,
                      style: AppTheme.h1WhiteBold,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.heroSubtitle,
                      style: AppTheme.bodyWhiteRegular.copyWith(color: AppTheme.inkInverse.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.espacioEntreSecciones),

              // 2. How it Works (Steps)
              Text(l10n.howItWorks, style: AppTheme.h2NavyBold),
              SizedBox(height: AppTheme.espacioEntreGrupos),
              Row(
                children: [
                  _StepItem(
                    icon: Icons.document_scanner, 
                    title: l10n.stepScan, 
                    subtitle: l10n.stepScanSubtitle, 
                    isFirst: true,
                    onTap: () => GoRouter.of(context).push('/services/help/scan'),
                  ),
                  const SizedBox(width: 8),
                  _StepItem(
                    icon: Icons.chat, 
                    title: l10n.stepSimulate, 
                    subtitle: l10n.stepSimulateSubtitle,
                    onTap: () => GoRouter.of(context).push('/services/help/simulate'),
                  ),
                  const SizedBox(width: 8),
                  _StepItem(
                    icon: Icons.assignment_turned_in, 
                    title: l10n.stepResults, 
                    subtitle: l10n.stepResultsSubtitle, 
                    isLast: true,
                     onTap: () => GoRouter.of(context).push('/services/help/results'),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.espacioEntreSecciones),

              // 3. Services Grid Title
              Text(l10n.popularServices, style: AppTheme.h2NavyBold),
              SizedBox(height: AppTheme.espacioEntreGrupos),

              // 4. Services Grid (Existing)
              // Card 1: New Application
              _ServiceCard(
                title: l10n.newVisaApplication,
                subtitle: l10n.newVisaSubtitle,
                icon: Icons.contact_page,
                badgeText: l10n.badgeFast,
                badgeColor: AppTheme.navyPrimary,
                badgeBg: AppTheme.softBlue,
                onTap: () => _handleNavigation(context, '/services/visa/select'),
              ),
              SizedBox(height: AppTheme.espacioEntreCampos),

              // Card 2: Simulator
              _ServiceCard(
                title: l10n.interviewSimulator,
                subtitle: l10n.interviewSimulatorSubtitle,
                icon: Icons.forum,
                badgeBg: AppTheme.softBlue,
                onTap: () => _handleSimulatorTap(context, ref),
              ),
              SizedBox(height: AppTheme.espacioEntreCampos),

              // Card 3: Audit
              _ServiceCard(
                title: l10n.documentAudit,
                subtitle: l10n.documentAuditSubtitle,
                icon: Icons.checklist,
                onTap: () => _handleNavigation(context, '/services/quick-check'),
              ),
              SizedBox(height: AppTheme.espacioEntreCampos),

              // Card 4: Cost Calculator
              _ServiceCard(
                title: l10n.costCalculatorTitle,
                subtitle: l10n.costCalculatorSubtitle,
                icon: Icons.calculate,
                onTap: () => _handleNavigation(context, '/services/cost/calculate'),
              ),
              SizedBox(height: AppTheme.espacioEntreCampos),

              // Card 5: Travel Ban
              _ServiceCard(
                title: l10n.travelBanTitle,
                subtitle: l10n.travelBanSubtitle,
                icon: Icons.public_off,
                onTap: () => _handleNavigation(context, '/services/travel-ban/check'),
              ),
              
              SizedBox(height: AppTheme.espacioEntreSecciones),

              // 4. Premium Access Section
              _buildSubscriptionSection(context, l10n),
              SizedBox(height: AppTheme.espacioEntreBloques),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.error(err.toString()))),
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.subscriptionTitle, style: AppTheme.h2NavyBold),
        SizedBox(height: AppTheme.espacioEntreGrupos),
        Row(
          children: [
            Expanded(
              child: _SubscriptionCard(
                title: l10n.planMonthly,
                price: l10n.priceMonthly,
                isBestValue: false,
                onTap: () => _handleNavigation(context, '/services/payment?plan=monthly'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SubscriptionCard(
                title: l10n.planYearly,
                price: l10n.priceYearly,
                isBestValue: true,
                badgeText: l10n.bestValue,
                onTap: () => _handleNavigation(context, '/services/payment?plan=yearly'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, String route) {
    GoRouter.of(context).push(route);
  }
  
  Future<void> _handleSimulatorTap(BuildContext context, WidgetRef ref) async {
    // Check if logged in via go_router redirect, or handle here?
    // The redirect at /services handles the TAB tap. This button is inside the app content.
    // We should replicate the logic or just push /simulator/chat and let guards handle it.
    // However, explicit check provides better UX (Toast/Snackbar) if desired.
    // For now, simple push. Router guards will redirect to login if needed.
    
    // Actually, user requested: "the icon... should take me to simulator".
    // For this card, we should also probably send them to simulator.
    GoRouter.of(context).push('/simulator/chat');
  }

  Widget _buildStatusCard(BuildContext context, DashboardData data, dynamic l10n) {
    Color statusColor = AppTheme.warningOrange;
    if (data.status == 'PAID' || data.status == 'SUBMITTED') {
      statusColor = AppTheme.successGreen;
    } else if (data.status == 'REJECTED') {
      statusColor = AppTheme.errorRed;
    }

    return Container(
      decoration: AppTheme.standardCardDecoration,
      child: Padding(
        padding: AppTheme.paddingEstandar,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.applicationStatus, style: AppTheme.labelBold),
                Container(
                  padding: AppTheme.paddingPequeno,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: AppTheme.badgeRadius,
                  ),
                  child: Text(
                    _translateStatus(data.status, l10n), 
                    style: AppTheme.h2NavyBold.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.espacioEntreSecciones),
            // Safely handle NaN or infinite progress
            LinearProgressIndicator(
              value: data.progress.isNaN ? 0.0 : data.progress.clamp(0.0, 1.0),
              backgroundColor: AppTheme.softBlue,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            SizedBox(height: AppTheme.espacioEntreCampos),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.percentComplete(((data.progress.isNaN ? 0.0 : data.progress) * 100).toInt())),
                Text(l10n.lastEdited(data.lastEdited)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _translateStatus(String status, dynamic l10n) {
    switch (status.toUpperCase()) {
      case 'DRAFT': return l10n.statusDraft;
      case 'PENDING_PAYMENT': return l10n.statusPendingPayment;
      case 'PAID': return l10n.statusPaid;
      case 'SUBMITTED': return l10n.statusSubmitted;
      case 'NOT_STARTED': return l10n.statusNotStarted;
      default: return status;
    }
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
        color: AppTheme.surfaceWhite, // Changed from inkInverse for consistency with Dashboard design
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.cardBorderColor),
        boxShadow: [
          BoxShadow(color: AppTheme.inkPrimary.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.cardRadius,
          child: Padding(
            padding: AppTheme.paddingPequeno,
            child: Row(
              children: [
                // Icon Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.navyPrimary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.navyPrimary, size: AppTheme.iconoEnTarjeta),
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
                              style: AppTheme.h2NavyBold, // Changed font style to match Dashboard
                            ),
                          ),
                          if (badgeText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsetsDirectional.only(start: 8),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: AppTheme.smallRadius,
                              ),
                              child: Text(
                                badgeText!,
                                style: AppTheme.labelBold.copyWith(
                                  color: badgeColor,
                                  fontSize: AppTheme.fuenteMini,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTheme.captionGreyRegular,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Arrow
                Icon(Icons.chevron_right, color: AppTheme.inkSecondary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final bool isBestValue;
  final String? badgeText;
  final VoidCallback onTap;

  const _SubscriptionCard({
    required this.title,
    required this.price,
    required this.isBestValue,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isBestValue ? AppTheme.navyPrimary : AppTheme.surfaceWhite,
            borderRadius: AppTheme.cardRadius,
            border: Border.all(
              color: isBestValue ? AppTheme.navyPrimary : AppTheme.cardBorderColor,
              width: isBestValue ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.inkPrimary.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppTheme.cardRadius,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (isBestValue) const SizedBox(height: 12), // Space for badge
                    Text(
                      title,
                      style: isBestValue 
                        ? AppTheme.labelRegular.copyWith(color: AppTheme.inkInverse.withValues(alpha: 0.8))
                        : AppTheme.labelRegular,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      price,
                      style: isBestValue 
                        ? AppTheme.h1WhiteBold.copyWith(fontSize: 20)
                        : AppTheme.h1NavyBold.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isBestValue && badgeText != null)
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700), // Gold
                  borderRadius: AppTheme.badgeRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeText!,
                  style: AppTheme.labelBold.copyWith(
                    color: AppTheme.navyPrimary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const _StepItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.inkInverse,
          borderRadius: AppTheme.buttonRadius,
          border: Border.all(color: AppTheme.cardBorderColor),
          boxShadow: [
            BoxShadow(color: AppTheme.inkPrimary.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),

        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppTheme.buttonRadius,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.navyPrimary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.navyPrimary, size: AppTheme.iconoMini),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: AppTheme.captionNavyBold.copyWith(
                    fontSize: AppTheme.fuenteCaption,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.captionGreyRegular.copyWith(fontSize: 9),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
