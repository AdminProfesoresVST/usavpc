/// Formulario prerrequisito para categoría de visa
/// Fuente: Supabase table `prerequisite_forms`
class PrerequisiteForm {
  final String id;
  final String visaCategoryCode;
  final String formCode;
  final String formName;
  final bool isMandatory;
  final String? conditionField;
  final String? conditionValue;
  final String issuedBy;
  final Map<String, dynamic> criticalFields;
  final String? helpText;
  final int orderIndex;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PrerequisiteForm({
    required this.id,
    required this.visaCategoryCode,
    required this.formCode,
    required this.formName,
    this.isMandatory = true,
    this.conditionField,
    this.conditionValue,
    required this.issuedBy,
    required this.criticalFields,
    this.helpText,
    this.orderIndex = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  })  : assert(id.isNotEmpty, 'PrerequisiteForm ID cannot be empty'),
        assert(formCode.isNotEmpty, 'Form code cannot be empty'),
        assert(formName.isNotEmpty, 'Form name cannot be empty'),
        assert(criticalFields.isNotEmpty, 'Critical fields cannot be empty');

  factory PrerequisiteForm.fromJson(Map<String, dynamic> json) {
    return PrerequisiteForm(
      id: json['id'] as String,
      visaCategoryCode: json['visa_category_code'] as String,
      formCode: json['form_code'] as String,
      formName: json['form_name'] as String,
      isMandatory: json['is_mandatory'] as bool? ?? true,
      conditionField: json['condition_field'] as String?,
      conditionValue: json['condition_value'] as String?,
      issuedBy: json['issued_by'] as String,
      criticalFields: Map<String, dynamic>.from(json['critical_fields'] as Map),
      helpText: json['help_text'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
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
      'visa_category_code': visaCategoryCode,
      'form_code': formCode,
      'form_name': formName,
      'is_mandatory': isMandatory,
      'condition_field': conditionField,
      'condition_value': conditionValue,
      'issued_by': issuedBy,
      'critical_fields': criticalFields,
      'help_text': helpText,
      'order_index': orderIndex,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Lista de campos requeridos
  List<String> get requiredFields => criticalFields.keys.toList();

  /// Verifica si este prerrequisito es condicional
  bool get isConditional => conditionField != null && conditionValue != null;

  /// Verifica si la condición se cumple para activar este prerrequisito
  bool checkCondition(Map<String, dynamic> formData) {
    if (!isConditional) return true;
    final actualValue = formData[conditionField];
    return actualValue?.toString() == conditionValue;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrerequisiteForm && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PrerequisiteForm($formCode for $visaCategoryCode)';
}

/// Estado de validación de prerrequisito
class PrerequisiteValidation {
  final String id;
  final String applicationId;
  final String prerequisiteFormId;
  final bool hasDocument;
  final Map<String, dynamic>? extractedData;
  final PrerequisiteStatus validationStatus;
  final String? blockedReason;
  final DateTime? validatedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PrerequisiteValidation({
    required this.id,
    required this.applicationId,
    required this.prerequisiteFormId,
    this.hasDocument = false,
    this.extractedData,
    this.validationStatus = PrerequisiteStatus.pending,
    this.blockedReason,
    this.validatedAt,
    required this.createdAt,
    this.updatedAt,
  }) : assert(id.isNotEmpty, 'PrerequisiteValidation ID cannot be empty');

  factory PrerequisiteValidation.fromJson(Map<String, dynamic> json) {
    return PrerequisiteValidation(
      id: json['id'] as String,
      applicationId: json['application_id'] as String,
      prerequisiteFormId: json['prerequisite_form_id'] as String,
      hasDocument: json['has_document'] as bool? ?? false,
      extractedData: json['extracted_data'] != null
          ? Map<String, dynamic>.from(json['extracted_data'] as Map)
          : null,
      validationStatus:
          PrerequisiteStatus.fromString(json['validation_status'] as String),
      blockedReason: json['blocked_reason'] as String?,
      validatedAt: json['validated_at'] != null
          ? DateTime.parse(json['validated_at'] as String)
          : null,
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
      'prerequisite_form_id': prerequisiteFormId,
      'has_document': hasDocument,
      'extracted_data': extractedData,
      'validation_status': validationStatus.value,
      'blocked_reason': blockedReason,
      'validated_at': validatedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PrerequisiteValidation copyWith({
    bool? hasDocument,
    Map<String, dynamic>? extractedData,
    PrerequisiteStatus? validationStatus,
    String? blockedReason,
    DateTime? validatedAt,
  }) {
    return PrerequisiteValidation(
      id: id,
      applicationId: applicationId,
      prerequisiteFormId: prerequisiteFormId,
      hasDocument: hasDocument ?? this.hasDocument,
      extractedData: extractedData ?? this.extractedData,
      validationStatus: validationStatus ?? this.validationStatus,
      blockedReason: blockedReason ?? this.blockedReason,
      validatedAt: validatedAt ?? this.validatedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// Estado de prerrequisito
enum PrerequisiteStatus {
  pending('pending'),
  valid('valid'),
  incomplete('incomplete'),
  blocked('blocked'),
  skipped('skipped'),
  notApplicable('not_applicable');

  final String value;
  const PrerequisiteStatus(this.value);

  static PrerequisiteStatus fromString(String value) {
    return PrerequisiteStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PrerequisiteStatus.pending,
    );
  }

  bool get canProceed =>
      this == valid || this == skipped || this == notApplicable;
}

/// Resultado de verificación de prerrequisitos
class PrerequisiteCheckResult {
  final bool canProceed;
  final List<PrerequisiteStatusItem> prerequisites;

  const PrerequisiteCheckResult({
    required this.canProceed,
    required this.prerequisites,
  });

  /// Items bloqueados
  List<PrerequisiteStatusItem> get blockedItems =>
      prerequisites.where((e) => e.status == PrerequisiteStatus.blocked).toList();

  /// Items incompletos
  List<PrerequisiteStatusItem> get incompleteItems =>
      prerequisites.where((e) => e.status == PrerequisiteStatus.incomplete).toList();
}

/// Item de estado de prerrequisito
class PrerequisiteStatusItem {
  final String formCode;
  final String formName;
  final PrerequisiteStatus status;
  final String? message;
  final String? helpText;
  final List<String>? missingFields;
  final List<String>? requiredFields;

  const PrerequisiteStatusItem({
    required this.formCode,
    required this.formName,
    required this.status,
    this.message,
    this.helpText,
    this.missingFields,
    this.requiredFields,
  });
}
