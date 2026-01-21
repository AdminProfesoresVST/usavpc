import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

/// Profile screen with full i18n support and consistent design.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final supabase = ref.watch(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    final displayName = user?.userMetadata?['full_name'] as String? ?? 
                        user?.email?.split('@').first ?? 
                        l10n.defaultUser;
    final email = user?.email ?? l10n.noEmail;

    return Scaffold(
      appBar: AppHeader(title: l10n.profileTitle),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.navyPrimary),
            accountName: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)), 
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 32, color: AppTheme.navyPrimary),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settingsOption),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsComingSoon)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(l10n.helpOption),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.contactSupport)),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppTheme.errorRed),
            title: Text(l10n.logoutOption, style: TextStyle(color: AppTheme.errorRed)),
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/services');
              }
            },
          ),
        ],
      ),
    );
  }
}
