import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';
import 'package:mobile/features/ocr/presentation/widgets/camera_mrz_widget.dart';

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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${context.l10n.passportDetected}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.push(
            '/kyc/confirm', 
            extra: result, // Pass the full PassportModel object
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraMRZWidget(
              onImage: _handleImage,
            ),
          ),
          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: Colors.black.withOpacity(0.5), width: 40),
                ),
              ),
              child: Center(
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellow, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          PositionedDirectional(
            top: 50,
            start: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
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
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isScanning ? l10n.searchingMRZ : l10n.detected,
                  style: TextStyle(
                    color: _isScanning ? Colors.yellow : Colors.green,
                    fontSize: 14,
                  ),
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
