import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';
import 'package:mobile/features/ocr/presentation/widgets/camera_mrz_widget.dart';

/// Production-ready passport scanner with real navigation.
/// Migration: 2026-01-20 - Implemented navigation with OCR data.
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
      setState(() => _isScanning = false); // Stop scanning immediately
      
      // Found valid MRZ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pasaporte Detectado!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // PRODUCTION: Navigate to KYC form with extracted data
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Pass OCR data to intake chat for auto-fill
          context.push(
            '/kyc/intake?surname=${result.lastName}&firstName=${result.firstName}&passport=${result.documentNumber}&dob=${result.birthDate}&nationality=${result.nationality}',
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The Camera Widget
          Positioned.fill(
            child: CameraMRZWidget(
              onImage: _handleImage,
            ),
          ),
          
          // Overlay UI (Scanner Frame)
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

          // Back Button Overlay
          Positioned(
            top: 50,
            left: 16,
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
          
          // Instruction Text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  "Escanee la zona de datos del pasaporte",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isScanning ? "Buscando MRZ..." : "¡Detectado!",
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
