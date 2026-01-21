import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_data.dart';

/// Production-ready dashboard with functional action tiles.
/// Migration: 2026-01-20 - Replaced "coming soon" with real navigation.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Solicitud', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF112E51),
        foregroundColor: Colors.white,
      ),
      body: dashboardAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(context, data),
              const SizedBox(height: 24),
              Text('Próximos Pasos', style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.bold)),
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
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, DashboardData data) {
    Color statusColor = Colors.amber;
    if (data.status == 'PAID' || data.status == 'SUBMITTED') {
      statusColor = Colors.green;
    } else if (data.status == 'REJECTED') {
      statusColor = Colors.red;
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
                Text('Estado de Solicitud', style: Theme.of(context).textTheme.titleMedium),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _translateStatus(data.status), 
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
                Text('${(data.progress * 100).toInt()}% Completado'),
                Text('Última edición: ${data.lastEdited}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT': return 'Borrador';
      case 'PENDING_PAYMENT': return 'Pendiente de Pago';
      case 'PAID': return 'Pagado';
      case 'SUBMITTED': return 'Enviado';
      case 'NOT_STARTED': return 'Sin Iniciar';
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
          backgroundColor: const Color(0xFF112E51).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF112E51)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _handleNavigation(context, iconCode),
      ),
    );
  }

  /// PRODUCTION: Route to appropriate screen based on action
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
        // All actions have real routes - no placeholders
        GoRouter.of(context).push('/services');
    }
  }
}
