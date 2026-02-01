import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/models/document_type.dart';
import 'package:mobile/models/user_document.dart';
import 'package:mobile/services/document_repository.dart';
import 'package:mobile/providers/visa_providers.dart';

/// ============================================================
/// REPOSITORY PROVIDER
/// ============================================================

import 'package:mobile/services/consular_photo_validator.dart';
import 'package:mobile/services/dashboard_repository_impl.dart'; // [FIX] Import for dashboardRepositoryProvider

/// Provider del repository de documentos
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(ref.watch(supabaseClientProvider));
});

/// Provider del validador de fotos consulares (AutoDispose cleans up resources)
final consularPhotoValidatorProvider = Provider.autoDispose<ConsularPhotoValidator>((ref) {
  final validator = ConsularPhotoValidator();
  ref.onDispose(() => validator.dispose());
  return validator;
});

/// ============================================================
/// DOCUMENT TYPES (Catalog)
/// ============================================================

/// Provider de todos los tipos de documento activos
final documentTypesProvider = FutureProvider<List<DocumentType>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentTypes();
});

/// Provider de tipos de documento requeridos para DS-160
final ds160DocumentTypesProvider = FutureProvider<List<DocumentType>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getRequiredDocumentsFor('DS160');
});

/// Provider de tipos de documento requeridos para DS-260
final ds260DocumentTypesProvider = FutureProvider<List<DocumentType>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getRequiredDocumentsFor('DS260');
});

/// Provider de tipo de documento por código
final documentTypeByCodeProvider = FutureProvider.family<DocumentType?, String>((ref, code) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentTypeByCode(code);
});

/// ============================================================
/// USER DOCUMENTS
/// ============================================================

/// Provider de todos los documentos del usuario actual
final userDocumentsProvider = FutureProvider<List<UserDocument>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getUserDocuments();
});

/// Provider de documento por tipo
final userDocumentByTypeProvider = FutureProvider.family<UserDocument?, String>((ref, typeId) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentByType(typeId);
});

/// ============================================================
/// DOCUMENT PROGRESS
/// ============================================================

/// Provider de progreso de documentos para DS-160
final documentProgressDs160Provider = FutureProvider<DocumentProgress>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentProgress(formType: 'DS160');
});

/// Provider de progreso de documentos para DS-260
final documentProgressDs260Provider = FutureProvider<DocumentProgress>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentProgress(formType: 'DS260');
});

/// Provider de progreso genérico (por tipo de formulario)
final documentProgressProvider = FutureProvider.family<DocumentProgress, String>((ref, formType) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocumentProgress(formType: formType);
});

/// ============================================================
/// COMBINED DATA PROVIDERS
/// ============================================================

/// Modelo combinado de tipo de documento + estado del usuario
class DocumentWithStatus {
  final DocumentType type;
  final UserDocument? userDocument;
  final bool isMandatory; // [NEW] Distinction between Required vs Optional

  DocumentWithStatus({
    required this.type,
    this.userDocument,
    this.isMandatory = false,
  });

  /// Si el documento ha sido subido
  bool get isUploaded => userDocument != null;

  /// Si el OCR está completo
  bool get isOcrComplete => userDocument?.ocrStatus == OcrStatus.complete;

  /// Si está verificado
  bool get isVerified => userDocument?.isVerified ?? false;

  /// Estado general del documento
  DocumentStatus get status {
    if (userDocument == null) return DocumentStatus.notUploaded;
    if (userDocument!.isVerified) return DocumentStatus.verified;
    if (userDocument!.ocrStatus == OcrStatus.complete) return DocumentStatus.scanned;
    if (userDocument!.ocrStatus == OcrStatus.processing) return DocumentStatus.processing;
    if (userDocument!.ocrStatus == OcrStatus.failed) return DocumentStatus.failed;
    return DocumentStatus.uploaded;
  }
}

/// Estados posibles de un documento
enum DocumentStatus {
  notUploaded,
  uploaded,
  processing,
  scanned,
  verified,
  failed,
}

/// Provider de documentos con estado para DS-160
final ds160DocumentsWithStatusProvider = FutureProvider<List<DocumentWithStatus>>((ref) async {
  // 1. Get raw list of all possible DS-160 documents
  final allTypes = await ref.watch(ds160DocumentTypesProvider.future);
  final userDocs = await ref.watch(userDocumentsProvider.future);
  
  // 2. Get User Profile to determine Visa Type
  final dashboardRepo = ref.watch(dashboardRepositoryProvider);
  final profileData = await dashboardRepo.getProfileData().catchError((_) => <String, dynamic>{});
  
  // Extract Visa Type from form_data or use logic
  final app = profileData['app'] as Map<String, dynamic>?;
  final formData = app?['form_data'] as Map<String, dynamic>?;
  // Try to find visa type in various possible locations
  final String visaType = (formData?['visa_type'] ?? formData?['visa_category'] ?? '').toString().toUpperCase();

  // 3. Define Logic: Who needs what?
  final bool isStudent = visaType.contains('F1') || visaType.contains('M1') || visaType.contains('J1');
  final bool isWorker = visaType.contains('H1B') || visaType.contains('L1');

  // 4. Map Types with Mandatory Flag (Instead of Filtering Out)
  return allTypes.map((type) {
    final code = type.code.toLowerCase();
    bool mandatory = false;
    
    // MANDATORY FOR EVERYONE (Universal)
    if (code == 'passport' || code.contains('photo') || code.contains('confirmation') || code.contains('ds160')) {
        mandatory = true;
    } 
    // Conditional: Student Documents
    else if (code.contains('i20') || code.contains('sevis')) {
        mandatory = isStudent;
    }
    // Conditional: Worker Documents
    else if (code.contains('petition') || code.contains('i797') || code.contains('labor')) {
        mandatory = isWorker;
    }
    
    // All others remain mandatory = false (Optional)

    final userDoc = userDocs.where((d) => d.documentTypeId == type.id).firstOrNull;
    return DocumentWithStatus(type: type, userDocument: userDoc, isMandatory: mandatory);
  }).toList();
});

/// Provider de documentos con estado para DS-260
final ds260DocumentsWithStatusProvider = FutureProvider<List<DocumentWithStatus>>((ref) async {
  final types = await ref.watch(ds260DocumentTypesProvider.future);
  final userDocs = await ref.watch(userDocumentsProvider.future);

  return types.map((type) {
    final userDoc = userDocs.where((d) => d.documentTypeId == type.id).firstOrNull;
    return DocumentWithStatus(type: type, userDocument: userDoc);
  }).toList();
});
