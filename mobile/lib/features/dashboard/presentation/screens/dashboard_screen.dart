import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_data.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: dashboardAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(context, data),
              const SizedBox(height: 24),
              Text('Next Steps', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              ...data.nextSteps.map((step) => _buildActionTile(
                context, 
                icon: _getIcon(step.iconCode), 
                title: step.title, 
                subtitle: step.subtitle,
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
                Text(
                  'Application Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(data.status, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: data.progress),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(data.progress * 100).toInt()}% Complete'),
                Text('Last edit: ${data.lastEdited}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String code) {
      switch (code) {
          case 'upload_file': return Icons.upload_file;
          case 'payment': return Icons.payment;
          default: return Icons.help;
      }
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (title.contains('Upload')) {
           // Basic logic to route based on content
           GoRouter.of(context).push('/kyc');
        } else if (title.contains('Pay')) {
           GoRouter.of(context).push('/payment');
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature coming soon')));
        }
      },
    );
  }
}
