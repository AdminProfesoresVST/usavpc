import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

class ServiceSelectionScreen extends ConsumerWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50 equivalent
      body: CustomScrollView(
        slivers: [
          // 1. Navy Navbar
          const SliverAppBar(
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Color(0xFF112E51), // Strict Navy
            title: Row(
              children: [
                Icon(Icons.policy, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Consular Assistant',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            actions: [
              // Profile Icon or similar could go here
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Hero Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF112E51), // Strict Navy
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'), // Subtle background
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Guía Oficial',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Simplifica tu Trámite Consular',
                        style: GoogleFonts.publicSans(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escanea documentos y simula tu entrevista para asegurar tu visa.',
                        style: GoogleFonts.publicSans(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // 3. How it Works (Steps)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text(
                    'Cómo funciona',
                    style: GoogleFonts.publicSans(
                      color: const Color(0xFF112E51),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StepItem(icon: Icons.document_scanner, title: 'Escanear', subtitle: 'Pasaporte', isFirst: true),
                      const SizedBox(width: 12),
                      _StepItem(icon: Icons.chat, title: 'Simular', subtitle: 'Entrevista AI'),
                      const SizedBox(width: 12),
                      _StepItem(icon: Icons.assignment_turned_in, title: 'Resultados', subtitle: 'Obtén Reporte', isLast: true),
                    ],
                  ),
                ),

                // 4. Popular Services
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Servicios Populares',
                        style: GoogleFonts.publicSans(
                          color: const Color(0xFF112E51),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ver todos',
                        style: GoogleFonts.publicSans(
                          color: const Color(0xFF112E51),
                          fontSize: 13,
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
                        title: 'Nueva Solicitud de Visa',
                        subtitle: 'Escanea tu ID para autocompletar formularios.',
                        icon: Icons.contact_page,
                        badgeText: 'RÁPIDO',
                        badgeColor: Colors.green.shade700,
                        badgeBg: Colors.green.shade50,
                        onTap: () => _handleNavigation(context, ref, '/visa-type'),
                      ),
                      
                      const SizedBox(height: 12),

                      // Card 2: Simulator
                      _ServiceCard(
                        title: 'Simulador de Entrevista',
                        subtitle: 'Practica preguntas reales con nuestra IA.',
                        icon: Icons.forum,
                        badgeText: 'RECOMENDADO',
                        badgeColor: Colors.blue.shade800,
                        badgeBg: Colors.blue.shade50,
                        onTap: () => _handleNavigation(context, ref, '/sim'),
                      ),

                      const SizedBox(height: 12),

                      // Card 3: Audit (Checklist)
                      _ServiceCard(
                        title: 'Auditoría de Documentos',
                        subtitle: 'Lista personalizada según tu tipo de visa.',
                        icon: Icons.checklist,
                        onTap: () => _handleNavigation(context, ref, '/sim'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 5. Trust Signal
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 14, color: Colors.green.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'Tus datos están seguros y encriptados.',
                          style: GoogleFonts.publicSans(
                            fontSize: 12,
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
      final isLoggedIn = ref.read(authStateProvider).valueOrNull != null;
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
                color: const Color(0xFF112E51).withOpacity(0.08), // Navy tint
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF112E51), size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF112E51)),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.publicSans(fontSize: 10, color: Colors.grey.shade500),
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
                    color: const Color(0xFF112E51).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF112E51), size: 24),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.publicSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF112E51),
                              ),
                            ),
                          ),
                          if (badgeText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(left: 8),
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
                        style: GoogleFonts.publicSans(
                          fontSize: 13,
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
