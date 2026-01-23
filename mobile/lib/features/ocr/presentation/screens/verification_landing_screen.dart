import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/core/widgets/dotted_border_painter.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';

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
           final uri = Uri(path: '/kyc/confirm', queryParameters: {
            'surname': result.lastName,
            'firstName': result.firstName,
            'passport': result.documentNumber,
            'dob': result.birthDate,
            'nationality': result.nationality,
            'sex': result.sex,
            'expiry': result.expiryDate,
          });
          context.push(uri.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ ${l10n.noValidPassport}'), backgroundColor: AppTheme.navyPrimary));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.navyPrimary));    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visaType = GoRouterState.of(context).uri.queryParameters['type'] ?? 'b1b2';

    return Scaffold(
      backgroundColor: Colors.white, // Pure White per reference
      appBar: AppHeader(title: l10n.verificationTitle),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.navyPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n.scanDocument, // "Upload ID"
                    style: AppTheme.h1NavyBold, // STRICT 18px
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.scanDocumentSubtitle,
                    style: AppTheme.bodyGreyRegular.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 48),

                  // DASHED CONTAINER
                  CustomPaint(
                    painter: DottedBorderPainter(color: Colors.grey.shade300, radius: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 1. Upload Section
                          GestureDetector(
                            onTap: _pickFromGallery,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundGrey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(LucideIcons.uploadCloud, size: 40, color: AppTheme.navyPrimary),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.uploadImage, // "Tap to upload photo"
                                  style: AppTheme.h2NavyBold, // 16px
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "PNG, JPG or PDF (max. 800x400px)", // Matches reference
                                  style: AppTheme.smallGreyRegular,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // 2. Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text("OR", style: AppTheme.smallGreyRegular.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade300)),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // 3. Camera Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.push('/identity/capture?type=$visaType'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.navyPrimary, // Navy Button
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text(
                                l10n.useCamera, // "Open camera"
                                style: AppTheme.h2NavyBold.copyWith(color: Colors.white), // 16px
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
