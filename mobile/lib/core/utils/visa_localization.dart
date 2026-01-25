import 'package:mobile/l10n/generated/app_localizations.dart';

class VisaLocalization {
  static String getVisaName(String code, String defaultName, AppLocalizations l10n) {
    switch (code) {
      case 'B1': return l10n.visaB1;
      case 'B2': return l10n.visaB2;
      case 'B1/B2': return l10n.visaB1B2;
      case 'F1': return l10n.visaF1;
      case 'F2': return l10n.visaF2;
      case 'M1': return l10n.visaM1;
      case 'J1': return l10n.visaJ1;
      case 'H1B': return l10n.visaH1B;
      case 'L1': return l10n.visaL1;
      case 'O1': return l10n.visaO1;
      case 'K1': return l10n.visaK1;
      case 'E1': return l10n.visaE1;
      case 'E2': return l10n.visaE2;
      default: return defaultName;
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
