/// Categoría de visa con tarifas y motor de formulario
/// Fuente: Supabase table `visa_categories`
class VisaCategory {
  final String id;
  final String code;
  final String name;
  final VisaType type;
  final FormEngine formEngine;
  final int baseFeeUsd;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VisaCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.formEngine,
    required this.baseFeeUsd,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  })  : assert(id.isNotEmpty, 'VisaCategory ID cannot be empty'),
        assert(code.isNotEmpty, 'VisaCategory code cannot be empty'),
        assert(name.isNotEmpty, 'VisaCategory name cannot be empty'),
        assert(baseFeeUsd > 0, 'Base fee must be positive');

  factory VisaCategory.fromJson(Map<String, dynamic> json) {
    return VisaCategory(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      type: VisaType.fromString(json['type'] as String),
      formEngine: FormEngine.fromString(json['form_engine'] as String),
      baseFeeUsd: json['base_fee_usd'] as int,
      description: json['description'] as String?,
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
      'code': code,
      'name': name,
      'type': type.value,
      'form_engine': formEngine.value,
      'base_fee_usd': baseFeeUsd,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Verifica si esta categoría requiere SEVIS (F1, M1, J1)
  bool get requiresSevis => ['F1', 'M1', 'J1'].contains(code);

  /// Verifica si es visa de trabajo con petición (H, L, O, P, Q, R)
  bool get requiresPetition =>
      ['H1B', 'H2A', 'H2B', 'L1', 'O1', 'P1', 'Q1', 'R1'].contains(code);

  /// Verifica si es visa de prometido
  bool get isFianceVisa => code == 'K1' || code == 'K2';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VisaCategory && other.id == id && other.code == code;
  }

  @override
  int get hashCode => Object.hash(id, code);

  @override
  String toString() => 'VisaCategory(code: $code, name: $name, fee: \$$baseFeeUsd)';
}

/// Tipo de visa: inmigrante o no inmigrante
enum VisaType {
  nonImmigrant('non_immigrant'),
  immigrant('immigrant');

  final String value;
  const VisaType(this.value);

  static VisaType fromString(String value) {
    return VisaType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid VisaType: $value'),
    );
  }

  bool get isImmigrant => this == VisaType.immigrant;
  bool get isNonImmigrant => this == VisaType.nonImmigrant;
}

/// Motor de formulario: DS-160 o DS-260
enum FormEngine {
  ds160('DS-160'),
  ds260('DS-260');

  final String value;
  const FormEngine(this.value);

  static FormEngine fromString(String value) {
    return FormEngine.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid FormEngine: $value'),
    );
  }
}
