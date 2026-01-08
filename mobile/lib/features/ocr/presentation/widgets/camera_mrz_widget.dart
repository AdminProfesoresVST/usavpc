import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraMRZWidget extends StatefulWidget {
  final Function(CameraImage image) onImage;

  const CameraMRZWidget({super.key, required this.onImage});

  @override
  State<CameraMRZWidget> createState() => _CameraMRZWidgetState();
}

class _CameraMRZWidgetState extends State<CameraMRZWidget> {
  CameraController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use the first "back" camera
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,  // Good for Android/MLKit
    );

    await _controller!.initialize();
    
    // Start Stream
    if (mounted) {
      setState(() {});
      await _controller!.startImageStream((image) async {
        if (_isProcessing) return;
        _isProcessing = true;
        try {
          await widget.onImage(image);
        } finally {
          _isProcessing = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return CameraPreview(_controller!);
  }
}
