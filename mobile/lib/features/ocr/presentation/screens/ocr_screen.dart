import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/ocr/logic/mrz_parser.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';

// No camera widget here anymore, reduces weight and prevents auto-init issues.

class OCRScreen extends ConsumerStatefulWidget {
  const OCRScreen({super.key});

  @override
  ConsumerState<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends ConsumerState<OCRScreen> {
  final OCRProcessor _processor = OCRProcessor(); // Still needed for gallery image processing
  final ImagePicker _picker = ImagePicker();
  
  bool _isProcessing = false;

  void _handlePassportFound(PassportModel passport) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pasaporte detectado: ${passport.firstName} ${passport.lastName}')),
    );

    final visaType = GoRouterState.of(context).uri.queryParameters['type'] ?? 'b1b2';
    
    context.push(
      '/chat-intake?type=$visaType&surname=${passport.lastName}&passport=${passport.documentNumber}&dob=${passport.birthDate}'
    );
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isProcessing = true);

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }

      final passport = await _processor.processFilePath(image.path);
      if (passport != null) {
        if (mounted) _handlePassportFound(passport);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se detectó pasaporte. Intente de nuevo.')),
          );
          setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar imagen: $e')),
          );
         setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _processor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF112E51), // Navy Background
      appBar: AppBar(
        title: Text(
          'Verificación de Documento',
          style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.document_scanner_outlined, size: 80, color: Colors.white70),
            const SizedBox(height: 24),
            Text(
              'Escanea tu Pasaporte',
              style: GoogleFonts.publicSans(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Para agilizar tu trámite, necesitamos extraer los datos de tu pasaporte automáticamente.',
              style: GoogleFonts.publicSans(
                fontSize: 16, 
                color: Colors.white70
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Option 1: Camera
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                // Force navigation to NEW Scan Screen
                onPressed: () {
                    final visaType = GoRouterState.of(context).uri.queryParameters['type'] ?? 'b1b2';
                    context.push('/ocr/scan?type=$visaType');
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('USAR CÁMARA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2440), // Darker Navy
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Option 2: Gallery
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('SUBIR DE GALERÍA'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            if (_isProcessing) ...[
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 8),
              Text(
                'Procesando imagen...',
                style: GoogleFonts.publicSans(color: Colors.white70, fontSize: 12),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
