/// Tarifa de visa
/// Fuente: Supabase table `visa_fees`
class VisaFee {
  final String id;
  final FeeType feeType;
  final String? visaCategoryCode;
  final String? countryCode;
  final int amountUsd;
  final bool isRefundable;
  final String? refundConditions;
  final DateTime effectiveDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VisaFee({
    required this.id,
    required this.feeType,
    this.visaCategoryCode,
    this.countryCode,
    required this.amountUsd,
    this.isRefundable = false,
    this.refundConditions,
    required this.effectiveDate,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  })  : assert(id.isNotEmpty, 'VisaFee ID cannot be empty'),
        assert(amountUsd >= 0, 'Amount cannot be negative');

  factory VisaFee.fromJson(Map<String, dynamic> json) {
    return VisaFee(
      id: json['id'] as String,
      feeType: FeeType.fromString(json['fee_type'] as String),
      visaCategoryCode: json['visa_category_code'] as String?,
      countryCode: json['country_code'] as String?,
      amountUsd: json['amount_usd'] as int,
      isRefundable: json['is_refundable'] as bool? ?? false,
      refundConditions: json['refund_conditions'] as String?,
      effectiveDate: DateTime.parse(json['effective_date'] as String),
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fee_type': feeType.value,
      'visa_category_code': visaCategoryCode,
      'country_code': countryCode,
      'amount_usd': amountUsd,
      'is_refundable': isRefundable,
      'refund_conditions': refundConditions,
      'effective_date': effectiveDate.toIso8601String().split('T').first,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisaFee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VisaFee(${feeType.value}: \$$amountUsd)';
}

/// Tipo de tarifa
enum FeeType {
  mrvBase('mrv_base'),
  integrityFee('integrity_fee'),
  i94Land('i94_land'),
  sevisI901('sevis_i901'),
  reciprocity('reciprocity'),
  premiumProcessing('premium_processing'),
  biometrics('biometrics');

  final String value;
  const FeeType(this.value);

  static FeeType fromString(String value) {
    return FeeType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid FeeType: $value'),
    );
  }

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case FeeType.mrvBase:
        return 'MRV Application Fee';
      case FeeType.integrityFee:
        return 'Visa Integrity Fee';
      case FeeType.i94Land:
        return 'I-94 Land Border Fee';
      case FeeType.sevisI901:
        return 'SEVIS I-901 Fee';
      case FeeType.reciprocity:
        return 'Reciprocity Fee';
      case FeeType.premiumProcessing:
        return 'Premium Processing';
      case FeeType.biometrics:
        return 'Biometrics Fee';
    }
  }
}

/// Item de desglose de costo
class CostBreakdownItem {
  final FeeType feeType;
  final int amountUsd;
  final String description;
  final bool isRefundable;
  final String? refundConditions;
  final bool isOptional;
  final String? notes;

  const CostBreakdownItem({
    required this.feeType,
    required this.amountUsd,
    required this.description,
    this.isRefundable = false,
    this.refundConditions,
    this.isOptional = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'fee_type': feeType.value,
      'amount_usd': amountUsd,
      'description': description,
      'is_refundable': isRefundable,
      'refund_conditions': refundConditions,
      'is_optional': isOptional,
      'notes': notes,
    };
  }

  factory CostBreakdownItem.fromJson(Map<String, dynamic> json) {
    return CostBreakdownItem(
      feeType: FeeType.fromString(json['fee_type'] as String),
      amountUsd: json['amount_usd'] as int,
      description: json['description'] as String,
      isRefundable: json['is_refundable'] as bool? ?? false,
      refundConditions: json['refund_conditions'] as String?,
      isOptional: json['is_optional'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

/// Cálculo de costo total
class CostCalculation {
  final String? id;
  final String? applicationId;
  final String? userId;
  final List<CostBreakdownItem> breakdown;
  final int totalUsd;
  final String countryCode;
  final String visaCategory;
  final bool crossingByLand;
  final bool includesSevis;
  final DateTime calculatedAt;

  CostCalculation({
    this.id,
    this.applicationId,
    this.userId,
    required this.breakdown,
    required this.totalUsd,
    required this.countryCode,
    required this.visaCategory,
    this.crossingByLand = false,
    this.includesSevis = false,
    DateTime? calculatedAt,
  })  : calculatedAt = calculatedAt ?? DateTime.now(),
        assert(breakdown.isNotEmpty, 'Breakdown cannot be empty'),
        assert(totalUsd >= 0, 'Total cannot be negative');

  factory CostCalculation.fromJson(Map<String, dynamic> json) {
    final breakdownJson = json['breakdown'] as List<dynamic>;
    return CostCalculation(
      id: json['id'] as String?,
      applicationId: json['application_id'] as String?,
      userId: json['user_id'] as String?,
      breakdown: breakdownJson
          .map((e) => CostBreakdownItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalUsd: json['total_usd'] as int,
      countryCode: json['country_code'] as String,
      visaCategory: json['visa_category'] as String,
      crossingByLand: json['crossing_by_land'] as bool? ?? false,
      includesSevis: json['includes_sevis'] as bool? ?? false,
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (applicationId != null) 'application_id': applicationId,
      if (userId != null) 'user_id': userId,
      'breakdown': breakdown.map((e) => e.toJson()).toList(),
      'total_usd': totalUsd,
      'country_code': countryCode,
      'visa_category': visaCategory,
      'crossing_by_land': crossingByLand,
      'includes_sevis': includesSevis,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  /// Total sin opcionales
  int get mandatoryTotal =>
      breakdown.where((e) => !e.isOptional).fold(0, (sum, e) => sum + e.amountUsd);

  /// Total de tarifas reembolsables
  int get refundableTotal =>
      breakdown.where((e) => e.isRefundable).fold(0, (sum, e) => sum + e.amountUsd);
}
