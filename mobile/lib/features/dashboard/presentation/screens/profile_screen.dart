import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PRODUCTION: Get real user data from Supabase
    final supabase = ref.watch(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    final displayName = user?.userMetadata?['full_name'] as String? ?? 
                        user?.email?.split('@').first ?? 
                        'Usuario';
    final email = user?.email ?? 'Sin correo';

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF112E51),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF112E51)),
            accountName: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)), 
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 32, color: Color(0xFF112E51)),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración próximamente')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ayuda y Soporte'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contacte: soporte@usavpc.org')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // PRODUCTION: Real logout
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
