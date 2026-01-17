import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';
import 'package:mobile/features/ocr/presentation/widgets/camera_mrz_widget.dart';

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
      
      // Navigate or Return Result here
      // context.pop(result); OR context.push('/kyc/fill', extra: result);
      // For now, just show success and pop after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.pop();
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
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              "Escanee la zona de datos del pasaporte",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
