/// Documento subido por un usuario
/// Fuente: Supabase table `user_documents`
class UserDocument {
  final String id;
  final String userId;
  final String? applicationId;
  final String documentTypeId;

  // File Storage
  final String storagePath;
  final String? originalFilename;
  final int? fileSizeBytes;
  final String? mimeType;

  // OCR Processing Status
  final OcrStatus ocrStatus;
  final Map<String, dynamic> ocrResult;
  final double? ocrConfidence;
  final DateTime? ocrProcessedAt;
  final String? ocrError;

  // Verification
  final bool isVerified;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? verificationNotes;

  // Metadata
  final DateTime uploadedAt;
  final DateTime updatedAt;

  UserDocument({
    required this.id,
    required this.userId,
    this.applicationId,
    required this.documentTypeId,
    required this.storagePath,
    this.originalFilename,
    this.fileSizeBytes,
    this.mimeType,
    this.ocrStatus = OcrStatus.pending,
    this.ocrResult = const {},
    this.ocrConfidence,
    this.ocrProcessedAt,
    this.ocrError,
    this.isVerified = false,
    this.verifiedBy,
    this.verifiedAt,
    this.verificationNotes,
    required this.uploadedAt,
    required this.updatedAt,
  })  : assert(id.isNotEmpty, 'UserDocument ID cannot be empty'),
        assert(userId.isNotEmpty, 'UserDocument userId cannot be empty'),
        assert(documentTypeId.isNotEmpty, 'DocumentType ID cannot be empty'),
        assert(storagePath.isNotEmpty, 'Storage path cannot be empty');

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      applicationId: json['application_id'] as String?,
      documentTypeId: json['document_type_id'] as String,
      storagePath: json['storage_path'] as String,
      originalFilename: json['original_filename'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      mimeType: json['mime_type'] as String?,
      ocrStatus: OcrStatus.fromString(json['ocr_status'] as String? ?? 'pending'),
      ocrResult: json['ocr_result'] as Map<String, dynamic>? ?? {},
      ocrConfidence: (json['ocr_confidence'] as num?)?.toDouble(),
      ocrProcessedAt: json['ocr_processed_at'] != null
          ? DateTime.parse(json['ocr_processed_at'] as String)
          : null,
      ocrError: json['ocr_error'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      verificationNotes: json['verification_notes'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'application_id': applicationId,
      'document_type_id': documentTypeId,
      'storage_path': storagePath,
      'original_filename': originalFilename,
      'file_size_bytes': fileSizeBytes,
      'mime_type': mimeType,
      'ocr_status': ocrStatus.value,
      'ocr_result': ocrResult,
      'ocr_confidence': ocrConfidence,
      'ocr_processed_at': ocrProcessedAt?.toIso8601String(),
      'ocr_error': ocrError,
      'is_verified': isVerified,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'verification_notes': verificationNotes,
      'uploaded_at': uploadedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Map for creating a new record (without id and timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'application_id': applicationId,
      'document_type_id': documentTypeId,
      'storage_path': storagePath,
      'original_filename': originalFilename,
      'file_size_bytes': fileSizeBytes,
      'mime_type': mimeType,
      'ocr_status': ocrStatus.value,
    };
  }

  /// Returns true if OCR has successfully extracted data
  bool get hasOcrData => ocrStatus == OcrStatus.complete && ocrResult.isNotEmpty;

  /// Returns true if document is ready (uploaded + OCR complete or not applicable)
  bool get isReady =>
      ocrStatus == OcrStatus.complete || ocrStatus == OcrStatus.notApplicable;

  /// Human-readable file size
  String get fileSizeFormatted {
    if (fileSizeBytes == null) return 'Unknown';
    if (fileSizeBytes! < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes! < 1024 * 1024) {
      return '${(fileSizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserDocument(id: $id, type: $documentTypeId, status: ${ocrStatus.value})';
}

/// Estado de procesamiento OCR
enum OcrStatus {
  pending('pending'),
  processing('processing'),
  complete('complete'),
  failed('failed'),
  notApplicable('not_applicable');

  final String value;
  const OcrStatus(this.value);

  static OcrStatus fromString(String value) {
    return OcrStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OcrStatus.pending,
    );
  }

  /// Localized display name
  String getDisplayName(String languageCode) {
    switch (this) {
      case OcrStatus.pending:
        return languageCode == 'es' ? 'Pendiente' : 'Pending';
      case OcrStatus.processing:
        return languageCode == 'es' ? 'Procesando...' : 'Processing...';
      case OcrStatus.complete:
        return languageCode == 'es' ? 'Escaneado' : 'Scanned';
      case OcrStatus.failed:
        return languageCode == 'es' ? 'Error' : 'Failed';
      case OcrStatus.notApplicable:
        return languageCode == 'es' ? 'No Aplica' : 'N/A';
    }
  }

  /// Whether this status indicates success
  bool get isSuccess => this == OcrStatus.complete;

  /// Whether this status indicates the document is being processed
  bool get isProcessing => this == OcrStatus.processing;

  /// Whether this status indicates a failure
  bool get isFailure => this == OcrStatus.failed;
}

/// Progress data for document completion
class DocumentProgress {
  final int totalRequired;
  final int totalUploaded;
  final int totalOcrComplete;
  final int totalVerified;
  final double progressPercentage;

  DocumentProgress({
    required this.totalRequired,
    required this.totalUploaded,
    required this.totalOcrComplete,
    required this.totalVerified,
    required this.progressPercentage,
  });

  factory DocumentProgress.fromJson(Map<String, dynamic> json) {
    return DocumentProgress(
      totalRequired: json['total_required'] as int? ?? 0,
      totalUploaded: json['total_uploaded'] as int? ?? 0,
      totalOcrComplete: json['total_ocr_complete'] as int? ?? 0,
      totalVerified: json['total_verified'] as int? ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Returns the status label based on progress
  String getStatusLabel(String languageCode) {
    if (totalUploaded == 0) {
      return languageCode == 'es' ? 'Sin Iniciar' : 'Not Started';
    }
    if (totalOcrComplete == totalRequired) {
      return languageCode == 'es' ? 'Documentos Completos' : 'Documents Complete';
    }
    return languageCode == 'es'
        ? '$totalOcrComplete de $totalRequired escaneados'
        : '$totalOcrComplete of $totalRequired scanned';
  }

  /// Display progress as fraction
  String get progressFraction => '$totalUploaded / $totalRequired';

  @override
  String toString() =>
      'DocumentProgress($totalUploaded/$totalRequired, ${progressPercentage.toStringAsFixed(1)}%)';
}
