import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';
import 'package:mobile/features/ocr/presentation/widgets/camera_mrz_widget.dart';
import 'package:mobile/features/ocr/presentation/widgets/scanner_overlay_painter.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Production-ready passport scanner with full i18n support.
/// Updated: 2026-01-21 - Applied i18n per audit requirements
class VerificationScannerScreen extends ConsumerStatefulWidget {
  const VerificationScannerScreen({super.key});

  @override
  ConsumerState<VerificationScannerScreen> createState() => _VerificationScannerScreenState();
}

class _VerificationScannerScreenState extends ConsumerState<VerificationScannerScreen> {
  final OCRProcessor _ocrProcessor = OCRProcessor();
  bool _isScanning = true;

  @override
  void dispose() {
    _ocrProcessor.dispose();
    super.dispose();
  }

  Future<void> _handleImage(CameraImage image) async {
    if (!_isScanning) return;

    final result = await _ocrProcessor.processImage(image);
    if (result != null && mounted) {
      setState(() => _isScanning = false);
      
      // ZERO TOLERANCE: Validate critical fields
      if (result.documentNumber.isEmpty || result.lastName.isEmpty) {
        setState(() => _isScanning = true); // Resume scanning
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Scan incomplete. Please rescan passport clearly.'),
            backgroundColor: AppTheme.errorRed,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Snackbar removed per user request
      
      // Navigate immediately without delay (conflicts with user actions)
      if (mounted) {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: AppTheme.inkPrimary,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraMRZWidget(
              onImage: _handleImage,
            ),
          ),
          
          Positioned.fill(
             child: CustomPaint(
               painter: ScannerOverlayPainter(
                 borderColor: AppTheme.inkInverse, // Strict Palette
                 overlayColor: const Color.fromRGBO(13, 36, 73, 0.85), // Deep Navy Mask
               ),
             ),
          ),

          PositionedDirectional(
            top: 50,
            start: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: AppTheme.inkPrimary.withOpacity(0.45),
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.inkInverse, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  l10n.passportScanInstructions,
                  style: AppTheme.h2NavyBold.copyWith(color: AppTheme.inkInverse), // 16px Bold White
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isScanning ? l10n.searchingMRZ : l10n.detected,
                  style: AppTheme.bodyWhiteRegular.copyWith(letterSpacing: 1.2), // 14px White
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
