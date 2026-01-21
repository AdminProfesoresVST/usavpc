import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';

class VerificationLandingScreen extends ConsumerStatefulWidget {
  const VerificationLandingScreen({super.key});

  @override
  ConsumerState<VerificationLandingScreen> createState() => _VerificationLandingScreenState();
}

class _VerificationLandingScreenState extends ConsumerState<VerificationLandingScreen> {
  final _picker = ImagePicker();
  final _ocrProcessor = OCRProcessor();
  bool _isLoading = false;

  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isLoading = true);
      
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Process Logic
      final result = await _ocrProcessor.processFilePath(image.path);
      
      if (mounted) {
      if (result != null) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Documento validado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to KYC form with extracted data
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.push('/kyc', extra: result);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ No se detectó un pasaporte válido. Intente de nuevo.'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _ocrProcessor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visaType = GoRouterState.of(context).uri.queryParameters['type'] ?? 'b1b2';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50 (Official Match)
      appBar: AppBar(
        title: Text(
          'VERIFICACIÓN DE IDENTIDAD',
          style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.navyPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.navyPrimary))
        : Column(
          children: [
            // Header Section (Navy Block)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              decoration: const BoxDecoration(
                color: AppTheme.navyPrimary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.scanLine, size: 40, color: Colors.white), // White instead of Gold
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Escanee su Documento',
                    style: GoogleFonts.publicSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Necesitamos capturar los datos de su pasaporte para autocompletar su solicitud.',
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                   _ActionCard(
                    title: 'Usar Cámara',
                    subtitle: 'Escanear directamente',
                    icon: LucideIcons.camera,
                    isPrimary: true,
                    onTap: () => context.push('/identity/capture?type=$visaType'),
                  ),
                  
                  const SizedBox(height: 16),

                  _ActionCard(
                    title: 'Subir Imagen',
                    subtitle: 'Desde galería',
                    icon: LucideIcons.image,
                    isPrimary: false,
                    onTap: _pickFromGallery,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Security Note
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.lock, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Sus datos están encriptados y seguros',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Subtle premium shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: isPrimary 
          ? Border.all(color: AppTheme.navyPrimary, width: 2) // Navy Border
          : Border.all(color: Colors.transparent),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isPrimary ? AppTheme.navyPrimary : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon, 
                    color: isPrimary ? Colors.white : AppTheme.navyPrimary, 
                    size: 24
                  ),
                ),
                const SizedBox(width: 16),
                
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.publicSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navyPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.publicSans(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  LucideIcons.chevronRight, 
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
