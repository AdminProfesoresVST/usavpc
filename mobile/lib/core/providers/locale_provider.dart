import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

/// Provider del locale actual de la aplicación.
/// Controla el idioma de la app y persiste la preferencia del usuario.
/// Added: 2026-01-21 - Implements dynamic language switching per multilingual-architect skill
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const String _localeKey = 'app_locale';
  
  /// Lista de idiomas soportados por la aplicación
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Español
  ];

  @override
  Locale build() {
    // Load saved locale asynchronously
    _loadSavedLocale();
    // Default to Spanish
    return const Locale('es');
  }

  /// Carga el idioma guardado en preferencias al iniciar la app
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      if (languageCode != null) {
        state = Locale(languageCode);
      }
    } catch (e) {
      // Si falla cargar preferencias, mantener español por defecto
    }
  }

  /// Cambia el idioma y lo persiste en SharedPreferences
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return; // Ignorar idiomas no soportados
    }
    
    state = locale;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Continuar aunque falle persistir - el cambio ya está en memoria
    }
  }

  /// Alterna entre inglés y español
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'en' 
        ? const Locale('es') 
        : const Locale('en');
    await setLocale(newLocale);
  }
}
