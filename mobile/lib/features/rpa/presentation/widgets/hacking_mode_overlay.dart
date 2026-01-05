import 'package:flutter/material.dart';
import 'dart:math';

class HackingModeOverlay extends StatefulWidget {
  const HackingModeOverlay({super.key});

  @override
  State<HackingModeOverlay> createState() => _HackingModeOverlayState();
}

class _HackingModeOverlayState extends State<HackingModeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<String> _codes = [
    '0x2F4A',
    'INJECTING...',
    'BYPASS_CACHE',
    '101101',
    'ROOT_ACCESS',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(10, (index) {
            return Positioned(
              left: _random.nextDouble() * MediaQuery.of(context).size.width,
              top: _random.nextDouble() * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: _random.nextDouble(),
                child: Text(
                  _codes[_random.nextInt(_codes.length)],
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'Courier',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
