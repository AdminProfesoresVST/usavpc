import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';

/// Verification landing screen with full i18n support.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
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
      final l10n = context.l10n;
      
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      final result = await _ocrProcessor.processFilePath(image.path);
      
      if (mounted) {
        if (result != null) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${l10n.documentValidated}'),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.push('/kyc', extra: result);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ ${l10n.noValidPassport}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.error(e.toString())), backgroundColor: AppTheme.errorRed),
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
    final l10n = context.l10n;
    final visaType = GoRouterState.of(context).uri.queryParameters['type'] ?? 'b1b2';

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppHeader(title: l10n.verificationTitle),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.navyPrimary))
        : Column(
          children: [
            // Header Section (Navy Block)
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 48),
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
                    child: const Icon(LucideIcons.scanLine, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.scanDocument,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.scanDocumentSubtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
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
                    title: l10n.useCamera,
                    subtitle: l10n.useCameraSubtitle,
                    icon: LucideIcons.camera,
                    isPrimary: true,
                    onTap: () => context.push('/identity/capture?type=$visaType'),
                  ),
                  
                  const SizedBox(height: 16),

                  _ActionCard(
                    title: l10n.uploadImage,
                    subtitle: l10n.uploadImageSubtitle,
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
              padding: const EdgeInsetsDirectional.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.lock, size: 14, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    l10n.dataSecure,
                    style: context.textTheme.bodySmall?.copyWith(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: isPrimary 
          ? Border.all(color: AppTheme.navyPrimary, width: 2)
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isPrimary ? AppTheme.navyPrimary : AppTheme.backgroundGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon, 
                    color: isPrimary ? Colors.white : AppTheme.navyPrimary, 
                    size: 24
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.navyPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(LucideIcons.chevronRight, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
