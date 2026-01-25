import 'package:mobile/l10n/generated/app_localizations.dart';

class VisaLocalization {
  /// Retorna el nombre localizado de una categoría de visa
  static String getVisaName(String code, String defaultName, AppLocalizations l10n) {
    switch (code) {
      // B Visas
      case 'B1': return l10n.visaB1Name;
      case 'B2': return l10n.visaB2Name;
      case 'B1/B2': return l10n.visaB1B2Name;
      // Conditional Resident
      case 'CR1': return l10n.visaCR1Name;
      case 'CR2': return l10n.visaCR2Name;
      // Diversity
      case 'DV': return l10n.visaDVName;
      // E Treaty Visas
      case 'E1': return l10n.visaE1Name;
      case 'E2': return l10n.visaE2Name;
      case 'E1/E2': return l10n.visaE1E2Name;
      // Employment Based
      case 'EB1': return l10n.visaEB1Name;
      case 'EB2': return l10n.visaEB2Name;
      case 'EB3': return l10n.visaEB3Name;
      case 'EB4': return l10n.visaEB4Name;
      case 'EB5': return l10n.visaEB5Name;
      // Student
      case 'F1': return l10n.visaF1Name;
      case 'F1_IMM': return l10n.visaF1IMMName;
      // Work
      case 'H1B': return l10n.visaH1BName;
      case 'H2A': return l10n.visaH2AName;
      case 'H2B': return l10n.visaH2BName;
      // Immediate Relatives
      case 'IR1': return l10n.visaIR1Name;
      case 'IR2': return l10n.visaIR2Name;
      case 'IR5': return l10n.visaIR5Name;
      // Exchange
      case 'J1': return l10n.visaJ1Name;
      // Fiance
      case 'K1': return l10n.visaK1Name;
      case 'K2': return l10n.visaK2Name;
      // Transfer
      case 'L1': return l10n.visaL1Name;
      // Vocational
      case 'M1': return l10n.visaM1Name;
      // Specialty
      case 'O1': return l10n.visaO1Name;
      case 'P1': return l10n.visaP1Name;
      case 'Q1': return l10n.visaQ1Name;
      case 'R1': return l10n.visaR1Name;
      // NAFTA
      case 'TN': return l10n.visaTNName;
      default: return defaultName;
    }
  }

  /// Retorna la descripción localizada de una categoría de visa
  static String getVisaDescription(String code, String defaultDesc, AppLocalizations l10n) {
    switch (code) {
      // B Visas
      case 'B1': return l10n.visaB1Desc;
      case 'B2': return l10n.visaB2Desc;
      case 'B1/B2': return l10n.visaB1B2Desc;
      // Conditional Resident
      case 'CR1': return l10n.visaCR1Desc;
      case 'CR2': return l10n.visaCR2Desc;
      // Diversity
      case 'DV': return l10n.visaDVDesc;
      // E Treaty Visas
      case 'E1': return l10n.visaE1Desc;
      case 'E2': return l10n.visaE2Desc;
      case 'E1/E2': return l10n.visaE1E2Desc;
      // Employment Based
      case 'EB1': return l10n.visaEB1Desc;
      case 'EB2': return l10n.visaEB2Desc;
      case 'EB3': return l10n.visaEB3Desc;
      case 'EB4': return l10n.visaEB4Desc;
      case 'EB5': return l10n.visaEB5Desc;
      // Student
      case 'F1': return l10n.visaF1Desc;
      case 'F1_IMM': return l10n.visaF1IMMDesc;
      // Work
      case 'H1B': return l10n.visaH1BDesc;
      case 'H2A': return l10n.visaH2ADesc;
      case 'H2B': return l10n.visaH2BDesc;
      // Immediate Relatives
      case 'IR1': return l10n.visaIR1Desc;
      case 'IR2': return l10n.visaIR2Desc;
      case 'IR5': return l10n.visaIR5Desc;
      // Exchange
      case 'J1': return l10n.visaJ1Desc;
      // Fiance
      case 'K1': return l10n.visaK1Desc;
      case 'K2': return l10n.visaK2Desc;
      // Transfer
      case 'L1': return l10n.visaL1Desc;
      // Vocational
      case 'M1': return l10n.visaM1Desc;
      // Specialty
      case 'O1': return l10n.visaO1Desc;
      case 'P1': return l10n.visaP1Desc;
      case 'Q1': return l10n.visaQ1Desc;
      case 'R1': return l10n.visaR1Desc;
      // NAFTA
      case 'TN': return l10n.visaTNDesc;
      default: return defaultDesc;
    }
  }

  static String getIssuedBy(String issuedBy, AppLocalizations l10n) {
    switch (issuedBy) {
      case 'school':
        return l10n.issuedBySchool;
      case 'uscis':
        return l10n.issuedByUSCIS;
      case 'sponsor_organization':
        return l10n.issuedBySponsor;
      case 'fmjfee.com':
        return 'fmjfee.com'; // Universally recognized domain
      case 'petitioner':
        return l10n.issuedByPetitioner;
      case 'state_department':
        return l10n.issuedByStateDept;
      default:
        return issuedBy;
    }
  }
}
