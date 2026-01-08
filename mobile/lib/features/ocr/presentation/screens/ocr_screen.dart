import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/ocr/logic/mrz_parser.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';
import 'package:mobile/features/ocr/presentation/widgets/camera_mrz_widget.dart';

enum OCRMode { intro, camera }

class OCRScreen extends ConsumerStatefulWidget {
  const OCRScreen({super.key});

  @override
  ConsumerState<OCRScreen> createState() => _OCRScreenState();
}

class _OCRScreenState extends ConsumerState<OCRScreen> {
  final OCRProcessor _processor = OCRProcessor();
  final ImagePicker _picker = ImagePicker();
  
  // Start in Intro mode as requested
  OCRMode _mode = OCRMode.intro;
  bool _isProcessing = false;

  void _handleImage(CameraImage image) async {
    if (_mode != OCRMode.camera || _isProcessing) return;

    final passport = await _processor.processImage(image);
    if (passport != null) {
      if (mounted) {
        setState(() => _isProcessing = true); // Stop processing more frames
        _handlePassportFound(passport);
      }
    }
  }

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
    // If in camera mode, use black background for immersive feel.
    // If in intro mode, use theme background.
    return Scaffold(
      backgroundColor: _mode == OCRMode.camera ? Colors.black : const Color(0xFF112E51),
      appBar: AppBar(
        title: Text(
          _mode == OCRMode.camera ? 'Escanear Pasaporte' : 'Verificación de Documento',
          style: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_mode == OCRMode.camera) {
              // If in camera, back goes to intro
              setState(() => _mode = OCRMode.intro);
            } else {
              // If in intro, back pops screen
              context.pop();
            }
          },
        ),
      ),
      body: _mode == OCRMode.intro ? _buildIntro() : _buildCamera(),
    );
  }

  Widget _buildIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF112E51), // Navy Background
      ),
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
              onPressed: () => setState(() => _mode = OCRMode.camera),
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
    );
  }

  Widget _buildCamera() {
    return Stack(
      children: [
        // 1. Camera Feed
        Positioned.fill(
          child: CameraMRZWidget(onImage: _handleImage),
        ),
        
        // 2. Overlay
        Positioned.fill(
          child: Container(
            decoration: ShapeDecoration(
              shape: _ScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
        ),

        // 3. Instructions (Bottom)
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'Alinee la página de datos',
                style: GoogleFonts.publicSans(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (_isProcessing)
                const CircularProgressIndicator(color: Colors.white)
              else
                 Text(
                   'Buscando código MRZ...',
                   style: GoogleFonts.publicSans(color: Colors.white70, fontSize: 12),
                 ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Overlay Shape
class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  const _ScannerOverlayShape({
    required this.borderColor,
    required this.borderWidth,
    required this.borderLength,
    required this.borderRadius,
    required this.cutOutSize,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero)
      ..addRect(_getCutOutRect(rect));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  Rect _getCutOutRect(Rect rect) {
    final width = rect.width - 40;
    final height = width * 0.63; // Passport ID-3 ratio
    return Rect.fromCenter(
      center: rect.center,
      width: width,
      height: height,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final cutOutRect = _getCutOutRect(rect);

    final Paint paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRect(cutOutRect),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();
    // Top Left
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top + borderRadius);
    path.quadraticBezierTo(cutOutRect.left, cutOutRect.top, cutOutRect.left + borderRadius, cutOutRect.top);
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);
    
    // Top Right
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right - borderRadius, cutOutRect.top);
    path.quadraticBezierTo(cutOutRect.right, cutOutRect.top, cutOutRect.right, cutOutRect.top + borderRadius);
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom Right
    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius);
    path.quadraticBezierTo(cutOutRect.right, cutOutRect.bottom, cutOutRect.right - borderRadius, cutOutRect.bottom);
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom Left
    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom);
    path.quadraticBezierTo(cutOutRect.left, cutOutRect.bottom, cutOutRect.left, cutOutRect.bottom - borderRadius);
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}


