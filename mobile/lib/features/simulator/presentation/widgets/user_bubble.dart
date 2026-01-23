import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// User message bubble widget - chat bubble style, right-aligned.
/// Created: 2026-01-23 - Chat bubbles UI redesign
/// Design: Blue bubble with white text, classic chat appearance.
class UserBubble extends StatelessWidget {
  final String text;

  const UserBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 16, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.actionBlue,
              AppTheme.actionBlue.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.actionBlue.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'PublicSans',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
