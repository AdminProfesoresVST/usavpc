import 'package:flutter/material.dart';
import 'package:mobile/l10n/arb/app_localizations.dart';

/// Extensiones de BuildContext para acceso más limpio a recursos comunes.
/// Added: 2026-01-21 - Implements context.l10n pattern per global-scale-master skill
extension BuildContextExtensions on BuildContext {
  /// Acceso rápido a las localizaciones de la app.
  /// Uso: context.l10n.loginTitle en lugar de AppLocalizations.of(context)!.loginTitle
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  
  /// Locale actual del contexto
  Locale get locale => Localizations.localeOf(this);
  
  /// Acceso rápido al ColorScheme del tema
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Acceso rápido al TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;
}
