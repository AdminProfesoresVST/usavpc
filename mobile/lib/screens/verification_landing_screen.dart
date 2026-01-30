import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/widgets/dotted_border_painter.dart';
import 'package:mobile/services/ocr_processor.dart';

/// Verification Landing Screen - "Clean Upload" Design
/// Matches User Reference: Dashed Border Container, Upload Top, Camera Bottom.
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
      // ... Same logic as before ...
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }
      final result = await _ocrProcessor.processFilePath(image.path);
      if (mounted) {
        if (result != null && result.documentNumber.isNotEmpty && result.lastName.isNotEmpty) {
           // Preserve existing params
           final currentParams = Map<String, String>.from(GoRouterState.of(context).uri.queryParameters);
           
           currentParams.addAll({
            'surname': result.lastName,
            'firstName': result.firstName,
            'passport': result.documentNumber,
            'dob': result.birthDate,
            'nationality': result.nationality,
            'sex': result.sex,
            'expiry': result.expiryDate,
          });
          
          final uri = Uri(path: '/kyc/confirm', queryParameters: currentParams);
          context.push(uri.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ ${l10n.noValidPassport}'), backgroundColor: AppTheme.navyPrimary));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.error(e.toString())), backgroundColor: AppTheme.navyPrimary));    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visaType = GoRouterState.of(context).uri.queryParameters['type'] ?? 'b1b2';

    return Scaffold(
      backgroundColor: AppTheme.inkInverse, // Pure White per reference
      appBar: AppHeader(title: l10n.verificationTitle),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.navyPrimary))
          : SingleChildScrollView(
              padding: AppTheme.paddingExtraGrande,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppTheme.espacioEntreSecciones),
                  Text(
                    l10n.scanDocument, // "Upload ID"
                    style: AppTheme.h1NavyBold, // STRICT 18px
                  ),
                  SizedBox(height: AppTheme.espacioEntreGrupos),
                  Text(
                    l10n.scanDocumentSubtitle,
                    style: AppTheme.labelRegular.copyWith(height: 1.5),
                  ),
                  SizedBox(height: AppTheme.espacioHero),

                  // DASHED CONTAINER
                   CustomPaint(
                    painter: DottedBorderPainter(color: AppTheme.inkSecondary, radius: AppTheme.cardRadiusValue),
                    child: Container(
                      width: double.infinity,
                      padding: AppTheme.paddingExtraGrande,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Upload Section
                          GestureDetector(
                            onTap: _pickFromGallery,
                            child: Column(
                              children: [
                                Container(
                                  padding: AppTheme.paddingMedio,
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundGrey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(LucideIcons.uploadCloud, size: AppTheme.iconoGrande, color: AppTheme.navyPrimary),
                                ),
                                SizedBox(height: AppTheme.espacioEntreSecciones),
                                Text(
                                  l10n.uploadImage, // "Tap to upload photo"
                                  style: AppTheme.h2NavyBold, // 16px
                                ),
                                SizedBox(height: AppTheme.espacioEntreCampos),
                                Text(
                                  l10n.uploadFormatInfo,
                                  style: AppTheme.captionGreyRegular,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppTheme.espacioEntreBloques),

                          // 2. Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppTheme.inkSecondary)),
                              Padding(
                                padding: AppTheme.paddingHorizontal,
                                child: Text(l10n.orSeparator, style: AppTheme.captionGreyRegular.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(child: Divider(color: AppTheme.inkSecondary)),
                            ],
                          ),

                          SizedBox(height: AppTheme.espacioEntreBloques),

                          // 3. Camera Button
                          SizedBox(
                            width: double.infinity,
                            height: AppTheme.alturaBotonGrande,
                            child: ElevatedButton(
                              onPressed: () {
                                final currentParams = GoRouterState.of(context).uri.queryParameters;
                                final uri = Uri(path: '/identity/capture', queryParameters: currentParams);
                                context.push(uri.toString());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.navyPrimary,
                                foregroundColor: AppTheme.inkInverse,
                                shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonRadius),
                                elevation: AppTheme.elevacionNula,
                              ),
                              child: Text(
                                l10n.useCamera,
                                style: AppTheme.h2WhiteBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
