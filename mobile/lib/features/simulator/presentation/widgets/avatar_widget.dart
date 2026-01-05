import 'package:flutter/material.dart';

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor(context),
        shape: BoxShape.circle,
        boxShadow: [
          if (state == AvatarState.speaking)
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 10,
            ),
        ],
      ),
      child: Center(
        child: Icon(
          _getIcon(),
          size: size * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getColor(BuildContext context) {
    switch (state) {
      case AvatarState.idle:
        return Colors.grey;
      case AvatarState.speaking:
        return Colors.green;
      case AvatarState.thinking:
        return Colors.amber;
    }
  }

  IconData _getIcon() {
    switch (state) {
      case AvatarState.idle:
        return Icons.person;
      case AvatarState.speaking:
        return Icons.record_voice_over;
      case AvatarState.thinking:
        return Icons.psychology;
    }
  }
}
