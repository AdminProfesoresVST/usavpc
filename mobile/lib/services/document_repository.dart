import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/document_type.dart';
import '../models/user_document.dart';

/// Repository para gestión de documentos
/// Maneja CRUD de tipos de documento y documentos de usuario
class DocumentRepository {
  final SupabaseClient _client;

  DocumentRepository(this._client);

  // ============================================================
  // DOCUMENT TYPES (Catalog - Read Only)
  // ============================================================

  /// Obtener todos los tipos de documento activos
  Future<List<DocumentType>> getDocumentTypes() async {
    final response = await _client
        .from('document_types')
        .select()
        .eq('is_active', true)
        .order('display_order');

    return (response as List)
        .map((json) => DocumentType.fromJson(json))
        .toList();
  }

  /// Obtener tipos de documento requeridos para un formulario específico
  Future<List<DocumentType>> getRequiredDocumentsFor(String formType) async {
    final response = await _client
        .from('document_types')
        .select()
        .eq('is_active', true)
        .contains('required_for', [formType])
        .order('display_order');

    return (response as List)
        .map((json) => DocumentType.fromJson(json))
        .toList();
  }

  /// Obtener un tipo de documento por código
  Future<DocumentType?> getDocumentTypeByCode(String code) async {
    final response = await _client
        .from('document_types')
        .select()
        .eq('code', code)
        .maybeSingle();

    if (response == null) return null;
    return DocumentType.fromJson(response);
  }

  // ============================================================
  // USER DOCUMENTS (Per-User CRUD)
  // ============================================================

  /// Obtener todos los documentos del usuario actual
  Future<List<UserDocument>> getUserDocuments() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('user_documents')
        .select()
        .eq('user_id', userId)
        .order('uploaded_at', ascending: false);

    return (response as List)
        .map((json) => UserDocument.fromJson(json))
        .toList();
  }

  /// Obtener documento por tipo
  Future<UserDocument?> getDocumentByType(String documentTypeId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('user_documents')
        .select()
        .eq('user_id', userId)
        .eq('document_type_id', documentTypeId)
        .maybeSingle();

    if (response == null) return null;
    return UserDocument.fromJson(response);
  }

  /// Subir un nuevo documento
  Future<UserDocument> uploadDocument({
    required String documentTypeId,
    required String storagePath,
    required String originalFilename,
    required int fileSizeBytes,
    required String mimeType,
    String? applicationId,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = {
      'user_id': userId,
      'application_id': applicationId,
      'document_type_id': documentTypeId,
      'storage_path': storagePath,
      'original_filename': originalFilename,
      'file_size_bytes': fileSizeBytes,
      'mime_type': mimeType,
      'ocr_status': 'pending',
    };

    final response = await _client
        .from('user_documents')
        .upsert(data, onConflict: 'user_id,document_type_id')
        .select()
        .single();

    return UserDocument.fromJson(response);
  }

  /// Actualizar estado de OCR (llamado por backend/Edge Function)
  Future<void> updateOcrStatus({
    required String documentId,
    required OcrStatus status,
    Map<String, dynamic>? ocrResult,
    double? confidence,
    String? error,
  }) async {
    final data = {
      'ocr_status': status.value,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (ocrResult != null) data['ocr_result'] = ocrResult;
    if (confidence != null) data['ocr_confidence'] = confidence;
    if (error != null) data['ocr_error'] = error;
    if (status == OcrStatus.complete || status == OcrStatus.failed) {
      data['ocr_processed_at'] = DateTime.now().toIso8601String();
    }

    await _client
        .from('user_documents')
        .update(data)
        .eq('id', documentId);
  }

  /// Eliminar un documento
  Future<void> deleteDocument(String documentId) async {
    await _client
        .from('user_documents')
        .delete()
        .eq('id', documentId);
  }

  // ============================================================
  // PROGRESS CALCULATION
  // ============================================================

  /// Obtener progreso de documentos del usuario
  Future<DocumentProgress> getDocumentProgress({String formType = 'DS160'}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .rpc('get_document_progress', params: {
          'p_user_id': userId,
          'p_form_type': formType,
        });

    if (response is List && response.isNotEmpty) {
      return DocumentProgress.fromJson(response.first);
    }

    // Default empty progress
    return DocumentProgress(
      totalRequired: 0,
      totalUploaded: 0,
      totalOcrComplete: 0,
      totalVerified: 0,
      progressPercentage: 0.0,
    );
  }

  // ============================================================
  // FILE STORAGE HELPERS
  // ============================================================

  /// Generar path de almacenamiento para un documento
  String generateStoragePath(String documentTypeCode, String filename) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = filename.split('.').last;
    return '$userId/${documentTypeCode}_$timestamp.$extension';
  }

  /// Obtener URL firmada para un documento
  Future<String> getSignedUrl(String storagePath, {int expiresIn = 3600}) async {
    final response = await _client.storage
        .from('documents')
        .createSignedUrl(storagePath, expiresIn);
    return response;
  }

  /// Subir archivo al storage
  Future<String> uploadFile({
    required String path,
    required List<int> fileBytes,
    required String mimeType,
  }) async {
    await _client.storage
        .from('documents')
        .uploadBinary(path, fileBytes as dynamic, fileOptions: FileOptions(contentType: mimeType));
    return path;
  }
}
