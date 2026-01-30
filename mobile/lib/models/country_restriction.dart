/// Restricción de viaje por país
/// Fuente: Supabase table `country_restrictions`
class CountryRestriction {
  final String id;
  final String countryCode;
  final String countryName;
  final RestrictionLevel restrictionLevel;
  final List<String>? restrictedCategories;
  final DateTime effectiveDate;
  final String? proclamationNumber;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CountryRestriction({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.restrictionLevel,
    this.restrictedCategories,
    required this.effectiveDate,
    this.proclamationNumber,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  })  : assert(id.isNotEmpty, 'CountryRestriction ID cannot be empty'),
        assert(countryCode.length == 2, 'Country code must be ISO 3166-1 alpha-2'),
        assert(countryName.isNotEmpty, 'Country name cannot be empty');

  factory CountryRestriction.fromJson(Map<String, dynamic> json) {
    return CountryRestriction(
      id: json['id'] as String,
      countryCode: json['country_code'] as String,
      countryName: json['country_name'] as String,
      restrictionLevel: RestrictionLevel.fromString(json['restriction_level'] as String),
      restrictedCategories: json['restricted_categories'] != null
          ? List<String>.from(json['restricted_categories'] as List)
          : null,
      effectiveDate: DateTime.parse(json['effective_date'] as String),
      proclamationNumber: json['proclamation_number'] as String?,
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
      'country_code': countryCode,
      'country_name': countryName,
      'restriction_level': restrictionLevel.value,
      'restricted_categories': restrictedCategories,
      'effective_date': effectiveDate.toIso8601String().split('T').first,
      'proclamation_number': proclamationNumber,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Verifica si una categoría específica está restringida
  bool isCategoryRestricted(String categoryCode) {
    if (restrictionLevel == RestrictionLevel.totalBan) return true;
    if (restrictionLevel == RestrictionLevel.none) return false;
    if (restrictedCategories == null) return false;
    return restrictedCategories!.contains(categoryCode);
  }

  /// Verifica si bloquea visas de inmigrante
  bool get blocksImmigrantVisas =>
      restrictionLevel == RestrictionLevel.totalBan ||
      restrictionLevel == RestrictionLevel.immigrantPause;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryRestriction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CountryRestriction($countryCode: ${restrictionLevel.value})';
}

/// Nivel de restricción de viaje
enum RestrictionLevel {
  totalBan('total_ban'),
  partialRestriction('partial_restriction'),
  immigrantPause('immigrant_pause'),
  none('none');

  final String value;
  const RestrictionLevel(this.value);

  static RestrictionLevel fromString(String value) {
    return RestrictionLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RestrictionLevel.none,
    );
  }

  /// Severidad para UI (0-3)
  int get severity {
    switch (this) {
      case RestrictionLevel.totalBan:
        return 3;
      case RestrictionLevel.partialRestriction:
        return 2;
      case RestrictionLevel.immigrantPause:
        return 1;
      case RestrictionLevel.none:
        return 0;
    }
  }

  /// Color hex para UI
  String get colorHex {
    switch (this) {
      case RestrictionLevel.totalBan:
        return '#D32F2F'; // Red
      case RestrictionLevel.partialRestriction:
        return '#F57C00'; // Orange
      case RestrictionLevel.immigrantPause:
        return '#FBC02D'; // Yellow
      case RestrictionLevel.none:
        return '#4CAF50'; // Green
    }
  }
}

/// Resultado de verificación de restricciones
class RestrictionCheckResult {
  final RestrictionLevel level;
  final String? countryName;
  final String? message;
  final bool canProceed;
  final List<String>? blockedCategories;

  const RestrictionCheckResult({
    required this.level,
    this.countryName,
    this.message,
    required this.canProceed,
    this.blockedCategories,
  });

  factory RestrictionCheckResult.allowed() {
    return const RestrictionCheckResult(
      level: RestrictionLevel.none,
      canProceed: true,
    );
  }

  factory RestrictionCheckResult.blocked({
    required RestrictionLevel level,
    required String countryName,
    required String message,
    List<String>? blockedCategories,
  }) {
    return RestrictionCheckResult(
      level: level,
      countryName: countryName,
      message: message,
      canProceed: false,
      blockedCategories: blockedCategories,
    );
  }
}
