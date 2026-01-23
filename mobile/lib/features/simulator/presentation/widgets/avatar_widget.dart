import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

enum AvatarState { idle, speaking, thinking }

class AvatarWidget extends StatelessWidget {
  final AvatarState state;
  final double size;

  const AvatarWidget({
    super.key,
    required this.state,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    // In production, this would be a RiveAnimation.asset(...)
    // For now, we simulate the logic with AnimatedContainer and color changes/icons
    // Delicate Design: Thin concentric circles instead of solid block
    Color primaryColor = _getColor(context);
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Ring (Pulsing if speaking)
          if (state == AvatarState.speaking)
             _PulseRing(color: primaryColor.withOpacity(0.1), size: size),
          
          // Inner Ring
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
            ),
          ),

          // Core Icon
          Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(
               color: state == AvatarState.speaking ? primaryColor.withOpacity(0.1) : Colors.transparent,
               shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(),
              size: size * 0.3,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(BuildContext context) {
    switch (state) {
      case AvatarState.idle:
        return Colors.grey.shade200;
      case AvatarState.speaking:
        return AppTheme.actionBlue; // Was Green
      case AvatarState.thinking:
        return AppTheme.navyPrimary; // Was Amber
    }
  }

  IconData _getIcon() {
    switch (state) {
      case AvatarState.idle:
        return Icons.person_outline;
      case AvatarState.speaking:
        return Icons.record_voice_over;
      case AvatarState.thinking:
        return Icons.hourglass_top; // More professional than psychology
    }
  }
}

class _PulseRing extends StatefulWidget {
  final Color color;
  final double size;
  const _PulseRing({required this.color, required this.size});
  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
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
           width: widget.size * (0.8 + (_controller.value * 0.2)),
           height: widget.size * (0.8 + (_controller.value * 0.2)),
           decoration: BoxDecoration(
             shape: BoxShape.circle,
             border: Border.all(color: widget.color.withOpacity(1 - _controller.value), width: 1),
           ),
         );
      },
    );
  }
}
