import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile/features/ocr/logic/mrz_parser.dart';

class OCRProcessor {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _isBusy = false;

  Future<PassportModel?> processImage(CameraImage image) async {
    if (_isBusy) return null;
    _isBusy = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return null;

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Extract lines
      final lines = recognizedText.blocks
          .expand((block) => block.lines)
          .map((line) => line.text)
          .toList();

      // Attempt MRZ Parse
      return MrzParser.parse(lines);
    } catch (e) {
      debugPrint('OCR Error: $e');
      return null;
    } finally {
      _isBusy = false;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }

  // Helper to convert CameraImage to InputImage (required by ML Kit)
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    
    // Hardcoded rotation for typical portrait mobile usage (90 degrees).
    // In a full production app, you should calculate this based on device sensor.
    const InputImageRotation imageRotation = InputImageRotation.rotation90deg;

    final InputImageFormat inputImageFormat = _platformFormat(image.format.group);

    // Newer MLKit versions use 'metadata' parameter with InputImageMetadata
    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  InputImageFormat _platformFormat(ImageFormatGroup group) {
      switch (group) {
        case ImageFormatGroup.bgra8888:
          return InputImageFormat.bgra8888;
        case ImageFormatGroup.yuv420:
          return InputImageFormat.yuv420;
        case ImageFormatGroup.nv21:
          return InputImageFormat.nv21;
        default:
          return InputImageFormat.yuv420;
      }
  }
}
