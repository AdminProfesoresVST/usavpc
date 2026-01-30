import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Widget de AppBar reutilizable para mantener consistencia de diseño.
/// Todas las pantallas secundarias (no la página principal) deben usar este widget.
/// Added: 2026-01-21 - Implements design consistency per flutter-ui-expert skill
///
/// Características:
/// - Fondo Navy (#112E51) consistente
/// - Tipografía Public Sans con peso w600
/// - Título centrado
/// - Iconos blancos
/// - Elevation 0 para diseño moderno flat
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Título a mostrar en el AppBar
  final String title;
  
  /// Acciones opcionales a la derecha del AppBar
  final List<Widget>? actions;
  
  /// Widget opcional a la izquierda (por defecto: botón de back si hay navigator)
  final Widget? leading;
  
  /// Si debe centrar el título (por defecto: true)
  final bool centerTitle;
  
  /// Widget opcional debajo del AppBar (ej: LinearProgressIndicator)
  final PreferredSizeWidget? bottom;
  
  /// Si debe mostrar automáticamente el botón de back
  final bool automaticallyImplyLeading;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.bottom,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          title,
          style: AppTheme.h1WhiteBold,
        ),
      ),
      backgroundColor: AppTheme.navyPrimary,
      foregroundColor: AppTheme.inkInverse,
      centerTitle: centerTitle,
      elevation: 0,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      iconTheme: const IconThemeData(color: AppTheme.inkInverse, size: AppTheme.iconoEnTarjeta),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

/// Variante de AppHeader con título dinámico (ej: con subtítulo o progreso)
class AppHeaderWithProgress extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final double? progress;
  final List<Widget>? actions;

  const AppHeaderWithProgress({
    super.key,
    required this.title,
    this.subtitle,
    this.progress,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        children: [
          Text(
            title,
            style: AppTheme.h1WhiteBold,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTheme.captionWhiteRegular.copyWith(color: AppTheme.inkInverse70),
            ),
        ],
      ),
      backgroundColor: AppTheme.navyPrimary,
      foregroundColor: AppTheme.inkInverse,
      centerTitle: true,
      elevation: 0,
      actions: actions,
      bottom: progress != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.inkInverse24,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.inkInverse),
              ),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (progress != null ? 4 : 0),
  );
}
