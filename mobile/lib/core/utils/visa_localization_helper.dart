import 'package:mobile/l10n/generated/app_localizations.dart';

/// Helper para obtener traducciones localizadas de categorías de visa
/// Los datos de Supabase vienen en inglés, este helper mapea el código
/// de visa a sus traducciones locales.
class VisaLocalizationHelper {
  /// Retorna el nombre localizado de una categoría de visa
  static String getLocalizedName(AppLocalizations l10n, String code) {
    // Normalizar código para la clave: E1/E2 -> E1E2, F1_IMM -> F1IMM
    final normalizedCode = code.replaceAll('/', '').replaceAll('_', '');
    
    final translations = _getTranslationMap(l10n);
    return translations['visa${normalizedCode}Name'] ?? code;
  }
  
  /// Retorna la descripción localizada de una categoría de visa
  static String getLocalizedDescription(AppLocalizations l10n, String code, String fallback) {
    final normalizedCode = code.replaceAll('/', '').replaceAll('_', '');
    
    final translations = _getTranslationMap(l10n);
    return translations['visa${normalizedCode}Desc'] ?? fallback;
  }
  
  /// Mapa de todas las traducciones disponibles
  static Map<String, String> _getTranslationMap(AppLocalizations l10n) {
    return {
      // B Visas
      'visaB1Name': l10n.visaB1Name,
      'visaB1Desc': l10n.visaB1Desc,
      'visaB1B2Name': l10n.visaB1B2Name,
      'visaB1B2Desc': l10n.visaB1B2Desc,
      'visaB2Name': l10n.visaB2Name,
      'visaB2Desc': l10n.visaB2Desc,
      // Conditional Resident
      'visaCR1Name': l10n.visaCR1Name,
      'visaCR1Desc': l10n.visaCR1Desc,
      'visaCR2Name': l10n.visaCR2Name,
      'visaCR2Desc': l10n.visaCR2Desc,
      // Diversity
      'visaDVName': l10n.visaDVName,
      'visaDVDesc': l10n.visaDVDesc,
      // E Treaty Visas
      'visaE1Name': l10n.visaE1Name,
      'visaE1Desc': l10n.visaE1Desc,
      'visaE1E2Name': l10n.visaE1E2Name,
      'visaE1E2Desc': l10n.visaE1E2Desc,
      'visaE2Name': l10n.visaE2Name,
      'visaE2Desc': l10n.visaE2Desc,
      // Employment-Based
      'visaEB1Name': l10n.visaEB1Name,
      'visaEB1Desc': l10n.visaEB1Desc,
      'visaEB2Name': l10n.visaEB2Name,
      'visaEB2Desc': l10n.visaEB2Desc,
      'visaEB3Name': l10n.visaEB3Name,
      'visaEB3Desc': l10n.visaEB3Desc,
      'visaEB4Name': l10n.visaEB4Name,
      'visaEB4Desc': l10n.visaEB4Desc,
      'visaEB5Name': l10n.visaEB5Name,
      'visaEB5Desc': l10n.visaEB5Desc,
      // Student
      'visaF1Name': l10n.visaF1Name,
      'visaF1Desc': l10n.visaF1Desc,
      'visaF1IMMName': l10n.visaF1IMMName,
      'visaF1IMMDesc': l10n.visaF1IMMDesc,
      // Work Visas
      'visaH1BName': l10n.visaH1BName,
      'visaH1BDesc': l10n.visaH1BDesc,
      'visaH2AName': l10n.visaH2AName,
      'visaH2ADesc': l10n.visaH2ADesc,
      'visaH2BName': l10n.visaH2BName,
      'visaH2BDesc': l10n.visaH2BDesc,
      // Immediate Relatives
      'visaIR1Name': l10n.visaIR1Name,
      'visaIR1Desc': l10n.visaIR1Desc,
      'visaIR2Name': l10n.visaIR2Name,
      'visaIR2Desc': l10n.visaIR2Desc,
      'visaIR5Name': l10n.visaIR5Name,
      'visaIR5Desc': l10n.visaIR5Desc,
      // Exchange
      'visaJ1Name': l10n.visaJ1Name,
      'visaJ1Desc': l10n.visaJ1Desc,
      // Fiancé
      'visaK1Name': l10n.visaK1Name,
      'visaK1Desc': l10n.visaK1Desc,
      'visaK2Name': l10n.visaK2Name,
      'visaK2Desc': l10n.visaK2Desc,
      // Transfer
      'visaL1Name': l10n.visaL1Name,
      'visaL1Desc': l10n.visaL1Desc,
      // Vocational
      'visaM1Name': l10n.visaM1Name,
      'visaM1Desc': l10n.visaM1Desc,
      // Specialty
      'visaO1Name': l10n.visaO1Name,
      'visaO1Desc': l10n.visaO1Desc,
      'visaP1Name': l10n.visaP1Name,
      'visaP1Desc': l10n.visaP1Desc,
      'visaQ1Name': l10n.visaQ1Name,
      'visaQ1Desc': l10n.visaQ1Desc,
      'visaR1Name': l10n.visaR1Name,
      'visaR1Desc': l10n.visaR1Desc,
      // NAFTA
      'visaTNName': l10n.visaTNName,
      'visaTNDesc': l10n.visaTNDesc,
    };
  }
}
