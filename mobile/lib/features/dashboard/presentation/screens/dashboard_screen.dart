import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_data.dart';

/// Production-ready dashboard with functional action tiles and full i18n.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppHeader(title: l10n.dashboardTitle),
      body: dashboardAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(context, data, l10n),
              const SizedBox(height: 24),
              Text(l10n.nextSteps, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...data.nextSteps.map((step) => _buildActionTile(
                context, 
                icon: _getIcon(step.iconCode), 
                title: step.title, 
                subtitle: step.subtitle,
                iconCode: step.iconCode,
              )),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.error(err.toString()))),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, DashboardData data, dynamic l10n) {
    Color statusColor = Colors.amber;
    if (data.status == 'PAID' || data.status == 'SUBMITTED') {
      statusColor = Colors.green;
    } else if (data.status == 'REJECTED') {
      statusColor = AppTheme.errorRed;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.applicationStatus, style: Theme.of(context).textTheme.titleMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _translateStatus(data.status, l10n), 
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: data.progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.percentComplete((data.progress * 100).toInt())),
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

  IconData _getIcon(String code) {
    switch (code) {
      case 'upload_file': return Icons.upload_file;
      case 'payment': return Icons.payment;
      case 'assessment': return Icons.assessment;
      case 'start': return Icons.play_arrow;
      default: return Icons.arrow_forward;
    }
  }

  Widget _buildActionTile(BuildContext context, {
    required IconData icon, 
    required String title, 
    required String subtitle,
    required String iconCode,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.navyPrimary.withOpacity(0.1),
          child: Icon(icon, color: AppTheme.navyPrimary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _handleNavigation(context, iconCode),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String iconCode) {
    switch (iconCode) {
      case 'upload_file':
        GoRouter.of(context).push('/kyc');
        break;
      case 'payment':
        GoRouter.of(context).push('/payment');
        break;
      case 'assessment':
        GoRouter.of(context).push('/risk-audit');
        break;
      case 'start':
        GoRouter.of(context).push('/visa-type');
        break;
      default:
        GoRouter.of(context).push('/services');
    }
  }
}
