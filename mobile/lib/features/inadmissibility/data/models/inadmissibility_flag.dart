/// Alerta de inadmisibilidad detectada
/// Fuente: Supabase table `inadmissibility_flags`
class InadmissibilityFlag {
  final String id;
  final String applicationId;
  final InadmissibilityType flagType;
  final Severity severity;
  final String? detectedFromField;
  final String? detectedValue;
  final String? suggestedWaiver;
  final String? waiverNotes;
  final bool userAcknowledged;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InadmissibilityFlag({
    required this.id,
    required this.applicationId,
    required this.flagType,
    required this.severity,
    this.detectedFromField,
    this.detectedValue,
    this.suggestedWaiver,
    this.waiverNotes,
    this.userAcknowledged = false,
    required this.createdAt,
    this.updatedAt,
  }) : assert(id.isNotEmpty, 'InadmissibilityFlag ID cannot be empty');

  factory InadmissibilityFlag.fromJson(Map<String, dynamic> json) {
    return InadmissibilityFlag(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      flagType: InadmissibilityType.fromString(json['flag_type'] as String),
      severity: Severity.fromString(json['severity'] as String),
      detectedFromField: json['detected_from_field'] as String?,
      detectedValue: json['detected_value'] as String?,
      suggestedWaiver: json['suggested_waiver'] as String?,
      waiverNotes: json['waiver_notes'] as String?,
      userAcknowledged: json['user_acknowledged'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'flag_type': flagType.value,
      'severity': severity.value,
      'detected_from_field': detectedFromField,
      'detected_value': detectedValue,
      'suggested_waiver': suggestedWaiver,
      'waiver_notes': waiverNotes,
      'user_acknowledged': userAcknowledged,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  InadmissibilityFlag copyWith({
    bool? userAcknowledged,
  }) {
    return InadmissibilityFlag(
      id: id,
      applicationId: applicationId,
      flagType: flagType,
      severity: severity,
      detectedFromField: detectedFromField,
      detectedValue: detectedValue,
      suggestedWaiver: suggestedWaiver,
      waiverNotes: waiverNotes,
      userAcknowledged: userAcknowledged ?? this.userAcknowledged,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InadmissibilityFlag && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Tipo de inadmisibilidad
enum InadmissibilityType {
  unlawfulPresence('unlawful_presence'),
  visaOverstay('visa_overstay'),
  criminalRecord('criminal_record'),
  immigrationFraud('immigration_fraud'),
  publicCharge('public_charge'),
  healthGrounds('health_grounds'),
  returningResident('returning_resident');

  final String value;
  const InadmissibilityType(this.value);

  static InadmissibilityType fromString(String value) {
    return InadmissibilityType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid InadmissibilityType: $value'),
    );
  }

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case InadmissibilityType.unlawfulPresence:
        return 'Unlawful Presence';
      case InadmissibilityType.visaOverstay:
        return 'Prior Visa Overstay';
      case InadmissibilityType.criminalRecord:
        return 'Criminal Record';
      case InadmissibilityType.immigrationFraud:
        return 'Immigration Fraud';
      case InadmissibilityType.publicCharge:
        return 'Public Charge Risk';
      case InadmissibilityType.healthGrounds:
        return 'Health Grounds';
      case InadmissibilityType.returningResident:
        return 'Returning Resident Issue';
    }
  }

  /// Descripción breve
  String get description {
    switch (this) {
      case InadmissibilityType.unlawfulPresence:
        return 'You spent more than 180 days in the US without authorization';
      case InadmissibilityType.visaOverstay:
        return 'You stayed beyond your authorized period on a previous visa';
      case InadmissibilityType.criminalRecord:
        return 'You have a criminal record that may affect admissibility';
      case InadmissibilityType.immigrationFraud:
        return 'There is a record of misrepresentation or fraud';
      case InadmissibilityType.publicCharge:
        return 'Your income may not meet the required threshold';
      case InadmissibilityType.healthGrounds:
        return 'Medical conditions that may affect admissibility';
      case InadmissibilityType.returningResident:
        return 'You were outside the US for an extended period';
    }
  }
}

/// Severidad de la alerta
enum Severity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const Severity(this.value);

  static Severity fromString(String value) {
    return Severity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Severity.low,
    );
  }

  /// Color hex para UI
  String get colorHex {
    switch (this) {
      case Severity.low:
        return '#4CAF50'; // Green
      case Severity.medium:
        return '#FFC107'; // Amber
      case Severity.high:
        return '#FF9800'; // Orange
      case Severity.critical:
        return '#F44336'; // Red
    }
  }
}

/// Documento de patrocinio financiero (I-134, I-864)
class FinancialSupportDoc {
  final String id;
  final String applicationId;
  final FinancialDocType docType;
  final String sponsorName;
  final String sponsorRelationship;
  final String? sponsorAddressUsa;
  final int? sponsorIncomeAnnualUsd;
  final int? sponsorAssetsUsd;
  final String? sponsorSsnLast4;
  final int householdSize;
  final bool isSigned;
  final String? documentUrl;
  final FinancialValidationStatus validationStatus;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FinancialSupportDoc({
    required this.id,
    required this.applicationId,
    required this.docType,
    required this.sponsorName,
    required this.sponsorRelationship,
    this.sponsorAddressUsa,
    this.sponsorIncomeAnnualUsd,
    this.sponsorAssetsUsd,
    this.sponsorSsnLast4,
    this.householdSize = 1,
    this.isSigned = false,
    this.documentUrl,
    this.validationStatus = FinancialValidationStatus.pending,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  })  : assert(id.isNotEmpty, 'FinancialSupportDoc ID cannot be empty'),
        assert(sponsorName.isNotEmpty, 'Sponsor name cannot be empty'),
        assert(householdSize > 0, 'Household size must be positive');

  factory FinancialSupportDoc.fromJson(Map<String, dynamic> json) {
    return FinancialSupportDoc(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      docType: FinancialDocType.fromString(json['doc_type'] as String),
      sponsorName: json['sponsor_name'] as String,
      sponsorRelationship: json['sponsor_relationship'] as String,
      sponsorAddressUsa: json['sponsor_address_usa'] as String?,
      sponsorIncomeAnnualUsd: json['sponsor_income_annual_usd'] as int?,
      sponsorAssetsUsd: json['sponsor_assets_usd'] as int?,
      sponsorSsnLast4: json['sponsor_ssn_last4'] as String?,
      householdSize: json['household_size'] as int? ?? 1,
      isSigned: json['is_signed'] as bool? ?? false,
      documentUrl: json['document_url'] as String?,
      validationStatus: FinancialValidationStatus.fromString(
          json['validation_status'] as String),
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'doc_type': docType.value,
      'sponsor_name': sponsorName,
      'sponsor_relationship': sponsorRelationship,
      'sponsor_address_usa': sponsorAddressUsa,
      'sponsor_income_annual_usd': sponsorIncomeAnnualUsd,
      'sponsor_assets_usd': sponsorAssetsUsd,
      'sponsor_ssn_last4': sponsorSsnLast4,
      'household_size': householdSize,
      'is_signed': isSigned,
      'document_url': documentUrl,
      'validation_status': validationStatus.value,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Calcula el umbral de pobreza requerido (125% del Federal Poverty Guideline)
  int get requiredIncome {
    const baseAmount = 15060;
    const perPersonAdd = 5380;
    final povertyLine = baseAmount + (perPersonAdd * (householdSize - 1));
    return (povertyLine * 1.25).round();
  }

  /// Verifica si el ingreso del patrocinador es suficiente
  bool get isIncomeSufficient {
    if (sponsorIncomeAnnualUsd == null) return false;
    return sponsorIncomeAnnualUsd! >= requiredIncome;
  }
}

enum FinancialDocType {
  i134('I-134'),
  i864('I-864');

  final String value;
  const FinancialDocType(this.value);

  static FinancialDocType fromString(String value) {
    return FinancialDocType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid FinancialDocType: $value'),
    );
  }
}

enum FinancialValidationStatus {
  pending('pending'),
  verified('verified'),
  insufficient('insufficient'),
  rejected('rejected');

  final String value;
  const FinancialValidationStatus(this.value);

  static FinancialValidationStatus fromString(String value) {
    return FinancialValidationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FinancialValidationStatus.pending,
    );
  }
}
