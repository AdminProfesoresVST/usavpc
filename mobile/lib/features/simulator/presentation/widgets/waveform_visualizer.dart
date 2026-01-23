import 'dart:math';
import 'package:flutter/material.dart';

/// Subtle waveform visualizer with thin animated lines in blue gradient variants.
/// Updated: 2026-01-23 - Made more subtle and elegant with color animation.
class WaveformVisualizer extends StatefulWidget {
  final bool isActive;
  final int barCount;

  const WaveformVisualizer({
    super.key,
    required this.isActive,
    this.barCount = 7,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer> with TickerProviderStateMixin {
  late List<AnimationController> _heightControllers;
  late List<Animation<double>> _heightAnimations;
  late AnimationController _colorController;
  late Animation<double> _colorAnimation;
  final Random _random = Random();

  // Blue gradient variants for smooth color transition
  static const List<Color> _blueVariants = [
    Color(0xFF90CAF9), // Light Blue 200
    Color(0xFF64B5F6), // Light Blue 300
    Color(0xFF42A5F5), // Blue 400
    Color(0xFF2196F3), // Blue 500
    Color(0xFF1E88E5), // Blue 600
    Color(0xFF1976D2), // Blue 700
  ];

  @override
  void initState() {
    super.initState();
    
    // Height animations - staggered for wave effect
    _heightControllers = List.generate(widget.barCount, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + _random.nextInt(400)),
      )..repeat(reverse: true);
    });

    _heightAnimations = _heightControllers.map((controller) {
      return Tween<double>(begin: 0.15, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutSine),
      );
    }).toList();

    // Color animation - cycles through blue variants
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _colorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    for (var controller in _heightControllers) {
      controller.dispose();
    }
    _colorController.dispose();
    super.dispose();
  }

  Color _getBarColor(int index) {
    // Create wave-like color distribution across bars
    final offset = (index / widget.barCount + _colorAnimation.value) % 1.0;
    final colorIndex = (offset * _blueVariants.length).floor() % _blueVariants.length;
    final nextColorIndex = (colorIndex + 1) % _blueVariants.length;
    final t = (offset * _blueVariants.length) - colorIndex;
    
    return Color.lerp(_blueVariants[colorIndex], _blueVariants[nextColorIndex], t)!;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.barCount, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 2,
            height: 3,
            decoration: BoxDecoration(
              color: _blueVariants[2].withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      );
    }

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            return AnimatedBuilder(
              animation: _heightAnimations[index],
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  width: 2, // Thin lines
                  height: 40 * _heightAnimations[index].value, // Larger height
                  decoration: BoxDecoration(
                    color: _getBarColor(index).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}
