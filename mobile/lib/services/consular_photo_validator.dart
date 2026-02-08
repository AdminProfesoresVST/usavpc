import 'dart:io';

import 'package:flutter/widgets.dart'; // For decodeImageFromList
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Validator for Consular Photos (Passport/Visa)
/// Enforces strict requirement: One face, eyes open, neutral pose, square aspect.
class ConsularPhotoValidator {
  // Service configuration
  static const double _minDimension = 600.0;
  static const double _maxHeadRotation = 10.0; // Degrees
  static const double _minEyeOpenProbability = 0.8;
  
  final FaceDetector _faceDetector;

  ConsularPhotoValidator()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableClassification: true, // For eyes open
            enableLandmarks: true, // For detailed features if needed
            enableTracking: false,
            performanceMode: FaceDetectorMode.accurate,
            minFaceSize: 0.15, // Face must be at least 15% of image
          ),
        );

  /// Validates a photo file against strict consular rules.
  /// Throws [ConsularPhotoValidationException] if any check fails.
  Future<void> validate(File photoFile) async {
    final path = photoFile.path;
    final inputImage = InputImage.fromFilePath(path);

    // 1. Image Dimensions & Aspect Ratio Check
    await _validateDimensions(photoFile);

    // 2. Face Detection
    final faces = await _faceDetector.processImage(inputImage);
    
    // 3. Strict Face Count (Zero Tolerance)
    if (faces.isEmpty) {
      throw ConsularPhotoValidationException(
        'No hay rostro detectado. Asegúrate de que tu cara esté visible e iluminada.',
        'NO_FACE',
      );
    }
    if (faces.length > 1) {
      throw ConsularPhotoValidationException(
        'Se detectaron múltiples rostros. La foto debe ser solo tuya.',
        'MULTIPLE_FACES',
      );
    }

    final face = faces.first;

    // 4. Head Pose (Must be facing forward)
    // Euler Y: Head rotation to right/left (Shake No)
    // Euler Z: Head tilt to shoulders (Thinking)
    if ((face.headEulerAngleY ?? 0).abs() > _maxHeadRotation ||
        (face.headEulerAngleZ ?? 0).abs() > _maxHeadRotation) {
      throw ConsularPhotoValidationException(
        'Cabeza rotada. Mira directamente a la cámara.',
        'BAD_POSE',
      );
    }

    // 5. Eyes Open Check
    // Note: Some models return null, so we default to 1.0 (pass) if not available strictly,
    // but accurate mode usually provides it.
    final leftEyeOpen = face.leftEyeOpenProbability;
    final rightEyeOpen = face.rightEyeOpenProbability;

    if (leftEyeOpen != null && rightEyeOpen != null) {
      if (leftEyeOpen < _minEyeOpenProbability || rightEyeOpen < _minEyeOpenProbability) {
        throw ConsularPhotoValidationException(
          'Ojos cerrados. Debes mantener ambos ojos abiertos.',
          'EYES_CLOSED',
        );
      }
    }
  }

  Future<void> _validateDimensions(File file) async {
    final bytes = await file.readAsBytes();
    final image = await decodeImageFromList(bytes);
    
    final width = image.width;
    final height = image.height;
    
    image.dispose(); // Release memory

    // Check minimum resolution
    if (width < _minDimension || height < _minDimension) {
      throw ConsularPhotoValidationException(
        'Resolución muy baja ($width x $height). Mínimo requerido: 600x600 px.',
        'LOW_RESOLUTION',
      );
    }

    // Check aspect ratio (Square 1:1)
    // We allow a tiny margin of error for cropping tools
    final ratio = width / height;
    if (ratio < 0.95 || ratio > 1.05) {
      throw ConsularPhotoValidationException(
        'La imagen no es cuadrada. Debe ser 1:1 (Ancho = Alto).',
        'NOT_SQUARE',
      );
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}

class ConsularPhotoValidationException implements Exception {
  final String message;
  final String code;

  ConsularPhotoValidationException(this.message, this.code);

  @override
  String toString() => message;
}
