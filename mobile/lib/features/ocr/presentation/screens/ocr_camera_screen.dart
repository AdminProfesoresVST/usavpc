import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/ocr/logic/mrz_parser.dart';
import 'package:mobile/features/ocr/logic/ocr_processor.dart';
import 'package:mobile/features/ocr/presentation/widgets/camera_mrz_widget.dart';

class OCRCameraScreen extends ConsumerStatefulWidget {
  const OCRCameraScreen({super.key});

  @override
  ConsumerState<OCRCameraScreen> createState() => _OCRCameraScreenState();
}

class _OCRCameraScreenState extends ConsumerState<OCRCameraScreen> {
  final OCRProcessor _processor = OCRProcessor();
  bool _isProcessing = false;

  void _handleImage(CameraImage image) async {
    if (_isProcessing) return;

    final passport = await _processor.processImage(image);
    if (passport != null) {
      if (mounted) {
        setState(() => _isProcessing = true);
        _handlePassportFound(passport);
      }
    }
  }

  void _handlePassportFound(PassportModel passport) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pasaporte detectado: ${passport.firstName} ${passport.lastName}')),
    );

    final visaType = GoRouterState.of(context).uri.queryParameters['type'] ?? 'b1b2';
    
    // Navigate to Chat Intake (replacing current stack or just pushing?)
    // If we push, back button goes to camera? Better to go to Chat.
    // User flow: Intro -> Camera -> Success -> Chat.
    context.push(
      '/chat-intake?type=$visaType&surname=${passport.lastName}&passport=${passport.documentNumber}&dob=${passport.birthDate}'
    );
  }

  @override
  void dispose() {
    _processor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Escanear Pasaporte',
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
      body: Stack(
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
      ),
    );
  }
}

// Custom Overlay Shape (Duplicated to avoid shared file dependency issues for now, or could move to widget)
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
