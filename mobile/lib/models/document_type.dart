/// Tipo de documento para visa (pasaporte, foto, acta, etc.)
/// Fuente: Supabase table `document_types`
class DocumentType {
  final String id;
  final String code;
  final String nameEn;
  final String nameEs;
  final String? descriptionEn;
  final String? descriptionEs;
  final DocumentCategory category;
  final List<String> requiredFor;
  final List<String> acceptedMimeTypes;
  final int maxFileSizeMb;
  final bool ocrExtractable;
  final int displayOrder;
  final bool isRequired;
  final bool isActive;
  final DateTime createdAt;

  DocumentType({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameEs,
    this.descriptionEn,
    this.descriptionEs,
    required this.category,
    required this.requiredFor,
    required this.acceptedMimeTypes,
    this.maxFileSizeMb = 10,
    this.ocrExtractable = true,
    this.displayOrder = 0,
    this.isRequired = true,
    this.isActive = true,
    required this.createdAt,
  })  : assert(id.isNotEmpty, 'DocumentType ID cannot be empty'),
        assert(code.isNotEmpty, 'DocumentType code cannot be empty'),
        assert(nameEn.isNotEmpty, 'DocumentType nameEn cannot be empty'),
        assert(nameEs.isNotEmpty, 'DocumentType nameEs cannot be empty');

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(
      id: json['id'] as String,
      code: json['code'] as String,
      nameEn: json['name_en'] as String,
      nameEs: json['name_es'] as String,
      descriptionEn: json['description_en'] as String?,
      descriptionEs: json['description_es'] as String?,
      category: DocumentCategory.fromString(json['category'] as String),
      requiredFor: (json['required_for'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      acceptedMimeTypes: (json['accepted_mime_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      maxFileSizeMb: json['max_file_size_mb'] as int? ?? 10,
      ocrExtractable: json['ocr_extractable'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
      isRequired: json['is_required'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name_en': nameEn,
      'name_es': nameEs,
      'description_en': descriptionEn,
      'description_es': descriptionEs,
      'category': category.value,
      'required_for': requiredFor,
      'accepted_mime_types': acceptedMimeTypes,
      'max_file_size_mb': maxFileSizeMb,
      'ocr_extractable': ocrExtractable,
      'display_order': displayOrder,
      'is_required': isRequired,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get localized name based on language code
  String getName(String languageCode) =>
      languageCode == 'es' ? nameEs : nameEn;

  /// Get localized description based on language code
  String? getDescription(String languageCode) =>
      languageCode == 'es' ? descriptionEs : descriptionEn;

  /// Check if this document is required for a specific form type
  bool isRequiredFor(String formType) => requiredFor.contains(formType);

  /// Check if a mime type is accepted
  bool acceptsMimeType(String mimeType) => acceptedMimeTypes.contains(mimeType);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentType && other.id == id && other.code == code;
  }

  @override
  int get hashCode => Object.hash(id, code);

  @override
  String toString() =>
      'DocumentType(code: $code, name: $nameEn, category: ${category.value})';
}

/// Categoría del documento
enum DocumentCategory {
  identity('identity'),
  civil('civil'),
  financial('financial'),
  supporting('supporting');

  final String value;
  const DocumentCategory(this.value);

  static DocumentCategory fromString(String value) {
    return DocumentCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid DocumentCategory: $value'),
    );
  }

  /// Localized display name
  String getDisplayName(String languageCode) {
    switch (this) {
      case DocumentCategory.identity:
        return languageCode == 'es' ? 'Identidad' : 'Identity';
      case DocumentCategory.civil:
        return languageCode == 'es' ? 'Documentos Civiles' : 'Civil Documents';
      case DocumentCategory.financial:
        return languageCode == 'es' ? 'Financieros' : 'Financial';
      case DocumentCategory.supporting:
        return languageCode == 'es' ? 'Documentos de Apoyo' : 'Supporting';
    }
  }
}
