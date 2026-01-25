import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

class VoiceControls extends StatelessWidget {
  final bool isListening;
  final VoidCallback onToggleListening;

  const VoiceControls({
    super.key,
    required this.isListening,
    required this.onToggleListening,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isListening)
          Container(
            height: AppTheme.alturaBotonGrande,
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                  child: _WaveBar(),
                );
              }),
            ),
          ),
        GestureDetector(
          onTap: onToggleListening,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: AppTheme.paddingEstandar,
            decoration: BoxDecoration(
              color: isListening ? AppTheme.errorRed : AppTheme.navyPrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: AppTheme.inkInverse,
              size: AppTheme.iconoMediano,
            ),
          ),
        ),
      ],
    );
  }
}

class _WaveBar extends StatefulWidget {
  const _WaveBar();

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
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
        return Container(
          width: 4,
          height: 10 + (20 * _controller.value),
          color: AppTheme.navyPrimary,
        );
      },
    );
  }
}
