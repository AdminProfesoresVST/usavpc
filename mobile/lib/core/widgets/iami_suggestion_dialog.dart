import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/services/ai_repository.dart';

/// Premium Dialog for IAMI Suggestions
/// Enforces AppTheme colors (Navy/Gold) and clean typography.
class IAMISuggestionDialog extends StatelessWidget {
  final IAMISuggestion suggestion;
  final String aiMessage;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IAMISuggestionDialog({
    super.key,
    required this.suggestion,
    required this.aiMessage,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.navyPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppTheme.accentGold, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mejora Sugerida',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PublicSans',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // AI Context Message
            Text(
              aiMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Comparison Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentGold.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original
                  Row(
                    children: [
                      Icon(Icons.close, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Text('Tu respuesta original:', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${suggestion.original}"',
                    style: TextStyle(
                      color: Colors.white60, 
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.redAccent,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                  
                  const Divider(color: Colors.white10, height: 24),
                  
                  // Improved
                  Row(
                    children: [
                      Icon(Icons.check, color: AppTheme.accentGold, size: 16),
                      const SizedBox(width: 8),
                      Text('Sugerencia Profesional:', style: TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${suggestion.improved}"',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reason
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text('📌 ', style: TextStyle(fontSize: 12)),
                ),
                Expanded(
                  child: Text(
                    suggestion.reason,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onReject,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Mantener Original', style: TextStyle(color: Colors.white54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.navyPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Aceptar Mejora', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
