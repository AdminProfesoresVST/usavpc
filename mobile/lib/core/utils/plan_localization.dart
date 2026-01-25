import 'package:mobile/l10n/generated/app_localizations.dart';

/// Helper para obtener traducciones localizadas de planes de servicio
class PlanLocalization {
  /// Retorna el título localizado de un plan
  static String getTitle(String planId, String defaultTitle, AppLocalizations l10n) {
    switch (planId) {
      case 'diy': return l10n.planDiyTitle;
      case 'full': return l10n.planFullTitle;
      case 'simulator': return l10n.planSimulatorTitle;
      default: return defaultTitle;
    }
  }

  /// Retorna la descripción localizada de un plan
  static String getDescription(String planId, String defaultDesc, AppLocalizations l10n) {
    switch (planId) {
      case 'diy': return l10n.planDiyDesc;
      case 'full': return l10n.planFullDesc;
      case 'simulator': return l10n.planSimulatorDesc;
      default: return defaultDesc;
    }
  }

  /// Retorna una feature localizada
  static String getFeature(String feature, AppLocalizations l10n) {
    switch (feature) {
      case 'AI Risk Assessment': return l10n.featureAIRiskAssessment;
      case 'VisaScore™ Report': return l10n.featureVisaScoreReport;
      case 'Document Checklist': return l10n.featureDocumentChecklist;
      case 'Email Support': return l10n.featureEmailSupport;
      case 'Everything in DIY': return l10n.featureEverythingInDIY;
      case 'DS-160 Auto-Fill': return l10n.featureDS160AutoFill;
      case 'Interview Prep Guide': return l10n.featureInterviewPrepGuide;
      case 'Priority Support': return l10n.featurePrioritySupport;
      case 'Money-Back Guarantee': return l10n.featureMoneyBackGuarantee;
      case 'Unlimited Practice Sessions': return l10n.featureUnlimitedPracticeSessions;
      case 'Real Consul Scenarios': return l10n.featureRealConsulScenarios;
      case 'Performance Analytics': return l10n.featurePerformanceAnalytics;
      case 'Weakness Analysis': return l10n.featureWeaknessAnalysis;
      default: return feature;
    }
  }

  /// Retorna lista de features localizadas
  static List<String> getFeatures(List<String> features, AppLocalizations l10n) {
    return features.map((f) => getFeature(f, l10n)).toList();
  }
}
