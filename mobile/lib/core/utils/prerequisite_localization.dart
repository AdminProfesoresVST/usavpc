import 'package:mobile/l10n/generated/app_localizations.dart';

/// Helper para obtener traducciones localizadas de formularios prerrequisito
class PrerequisiteLocalization {
  /// Retorna el nombre localizado de un formulario
  static String getFormName(String formCode, String defaultName, AppLocalizations l10n) {
    switch (formCode) {
      case 'DS-2019': return l10n.formDS2019Name;
      case 'I-129S': return l10n.formI129SName;
      case 'I-20': return l10n.formI20Name;
      case 'I-797': return l10n.formI797Name;
      default: return defaultName;
    }
  }

  /// Retorna el texto de ayuda localizado de un formulario
  static String getHelpText(String formCode, String defaultHelp, AppLocalizations l10n, {bool isVocational = false}) {
    switch (formCode) {
      case 'DS-2019': return l10n.formDS2019Help;
      case 'I-129S': return l10n.formI129SHelp;
      case 'I-20': return isVocational ? l10n.formI20HelpVocational : l10n.formI20HelpAcademic;
      case 'I-797': return l10n.formI797Help;
      default: return defaultHelp;
    }
  }

  /// Retorna el emisor localizado
  static String getIssuedBy(String issuedBy, AppLocalizations l10n) {
    switch (issuedBy) {
      case 'Program Sponsor': return l10n.issuedByProgramSponsor;
      case 'Employer': return l10n.issuedByEmployer;
      case 'DHS/SEVP School': return l10n.issuedByDHSSEVPSchool;
      case 'USCIS': return l10n.issuedByUSCIS;
      default: return issuedBy;
    }
  }
}
