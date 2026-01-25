import 'package:mobile/l10n/generated/app_localizations.dart';

/// Helper para obtener traducciones localizadas de restricciones de viaje
class RestrictionLocalization {
  /// Retorna el nivel de restricción localizado
  static String getRestrictionLevel(String level, AppLocalizations l10n) {
    switch (level) {
      case 'total_ban': return l10n.restrictionTotalBan;
      case 'partial_ban': return l10n.restrictionPartialBan;
      case 'enhanced_vetting': return l10n.restrictionEnhancedVetting;
      default: return level;
    }
  }

  /// Retorna la nota de restricción localizada
  static String getRestrictionNote(String note, AppLocalizations l10n) {
    switch (note) {
      case 'Complete entry prohibition': return l10n.restrictionCompleteEntryProhibition;
      default: return note;
    }
  }
}
