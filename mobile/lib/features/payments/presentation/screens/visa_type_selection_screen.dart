import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class VisaTypeSelectionScreen extends ConsumerWidget {
  const VisaTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Subtle Grey
      appBar: AppBar(
        title: Text(
          'Propósito del Viaje', // Spanish, Professional
          style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF112E51), // Navy
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Elegant Header
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Seleccione la categoría que mejor describe su motivo de viaje a los Estados Unidos.',
              style: TextStyle(
                color: Color(0xFF4B5563), // Dark Grey
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),

          // Option 1: Turismo (B1/B2)
          _CompactVisaTile(
            title: 'Turismo, Negocios y Visitas',
            description: 'Vacaciones, compras, visitar familia o reuniones.',
            icon: Icons.beach_access_outlined, // Fine line
            onTap: () => context.push('/ocr'),
          ),
          
          const SizedBox(height: 12),

          // Option 2: Renovation
          _CompactVisaTile(
            title: 'Renovación de Visa',
            description: 'Renovar una visa vencida o por vencer.',
            icon: Icons.refresh_outlined, // Fine line
            onTap: () => context.push('/ocr'),
          ),

          const SizedBox(height: 12),

          // Option 3: Trabajo
          _CompactVisaTile(
            title: 'Trabajo Temporal',
            description: 'Agricultura, construcción u otros trabajos estacionales.',
            icon: Icons.work_outline, // Fine line
            onTap: () => context.push('/ocr?type=h2'), // Proceed to flow
          ),

          const SizedBox(height: 12),

          // Option 4: Estudiante
          _CompactVisaTile(
            title: 'Estudiante',
            description: 'Estudios académicos o de idiomas.',
            icon: Icons.school_outlined, // Fine line
            onTap: () => context.push('/ocr?type=f1'), // Proceed to flow
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Icon(icon, color: const Color(0xFF112E51), size: 22),
                
                const SizedBox(width: 14),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF112E51),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chevron
                 Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
