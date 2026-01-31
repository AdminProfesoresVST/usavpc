import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/models/document_type.dart';
import 'package:mobile/providers/document_providers.dart';

/// Widget que muestra el checklist de documentos requeridos con estado
class DocumentChecklist extends ConsumerWidget {
  final String formType;

  const DocumentChecklist({
    super.key,
    this.formType = 'DS160',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = formType == 'DS260'
        ? ref.watch(ds260DocumentsWithStatusProvider)
        : ref.watch(ds160DocumentsWithStatusProvider);

    return documentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: TextStyle(color: AppTheme.errorRed)),
      ),
      data: (documents) => _buildChecklist(context, ref, documents),
    );
  }

  Widget _buildChecklist(
    BuildContext context,
    WidgetRef ref,
    List<DocumentWithStatus> documents,
  ) {
    // Group by category
    final grouped = <DocumentCategory, List<DocumentWithStatus>>{};
    for (final doc in documents) {
      grouped.putIfAbsent(doc.type.category, () => []).add(doc);
    }

    final languageCode = context.locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Header
        _buildProgressHeader(context, documents),
        SizedBox(height: AppTheme.espacioEntreSecciones),

        // Document tiles by category
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category label
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  entry.key.getDisplayName(languageCode),
                  style: AppTheme.labelBold.copyWith(color: AppTheme.navyPrimary),
                ),
              ),
              // Document tiles
              ...entry.value.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DocumentUploadTile(
                      documentWithStatus: doc,
                      languageCode: languageCode,
                    ),
                  )),
              SizedBox(height: AppTheme.espacioEntreCampos),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    List<DocumentWithStatus> documents,
  ) {
    final l10n = context.l10n;
    final total = documents.length;
    final uploaded = documents.where((d) => d.isUploaded).length;
    final scanned = documents.where((d) => d.isOcrComplete).length;
    final progress = total > 0 ? uploaded / total : 0.0;

    return Container(
      padding: AppTheme.paddingEstandar,
      decoration: BoxDecoration(
        color: AppTheme.navyPrimary.withValues(alpha: 0.05),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.navyPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.requiredDocuments,
                style: AppTheme.h2NavyBold,
              ),
              Container(
                padding: AppTheme.paddingPequeno,
                decoration: BoxDecoration(
                  color: _getProgressColor(progress).withValues(alpha: 0.15),
                  borderRadius: AppTheme.badgeRadius,
                ),
                child: Text(
                  '$uploaded / $total',
                  style: AppTheme.captionNavyBold.copyWith(
                    color: _getProgressColor(progress),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.espacioEntreCampos),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.softBlue,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
            ),
          ),
          SizedBox(height: AppTheme.espacioEntreCampos),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$scanned ${l10n.documentsScanned}',
                style: AppTheme.captionGreyRegular,
              ),
              Text(
                '${(progress * 100).toInt()}% ${l10n.complete}',
                style: AppTheme.captionGreyRegular,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppTheme.successGreen;
    if (progress >= 0.5) return AppTheme.navyPrimary;
    return AppTheme.warningOrange;
  }
}

/// Tile individual para subir un documento
class DocumentUploadTile extends ConsumerStatefulWidget {
  final DocumentWithStatus documentWithStatus;
  final String languageCode;

  const DocumentUploadTile({
    super.key,
    required this.documentWithStatus,
    required this.languageCode,
  });

  @override
  ConsumerState<DocumentUploadTile> createState() => _DocumentUploadTileState();
}

class _DocumentUploadTileState extends ConsumerState<DocumentUploadTile> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final doc = widget.documentWithStatus;
    final type = doc.type;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(
          color: _getBorderColor(doc.status),
          width: doc.isUploaded ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: AppTheme.paddingPequeno,
        leading: _buildStatusIcon(doc.status),
        title: Text(
          type.getName(widget.languageCode),
          style: AppTheme.labelBold,
        ),
        subtitle: Text(
          _getStatusText(doc),
          style: AppTheme.captionGreyRegular.copyWith(
            color: _getStatusTextColor(doc.status),
          ),
        ),
        trailing: _buildActionButton(doc),
        onTap: doc.isUploaded ? () => _showDocumentPreview(doc) : () => _uploadDocument(type),
      ),
    );
  }

  Widget _buildStatusIcon(DocumentStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case DocumentStatus.verified:
        icon = Icons.verified;
        color = AppTheme.successGreen;
      case DocumentStatus.scanned:
        icon = Icons.check_circle;
        color = AppTheme.navyPrimary;
      case DocumentStatus.processing:
        icon = Icons.hourglass_top;
        color = AppTheme.warningOrange;
      case DocumentStatus.uploaded:
        icon = Icons.upload_file;
        color = AppTheme.navyPrimary;
      case DocumentStatus.failed:
        icon = Icons.error;
        color = AppTheme.errorRed;
      case DocumentStatus.notUploaded:
        icon = Icons.upload_outlined;
        color = AppTheme.cardBorderColor;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getBorderColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppTheme.successGreen;
      case DocumentStatus.scanned:
        return AppTheme.navyPrimary;
      case DocumentStatus.processing:
        return AppTheme.warningOrange;
      case DocumentStatus.failed:
        return AppTheme.errorRed;
      default:
        return AppTheme.cardBorderColor;
    }
  }

  Color _getStatusTextColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return AppTheme.successGreen;
      case DocumentStatus.scanned:
        return AppTheme.navyPrimary;
      case DocumentStatus.processing:
        return AppTheme.warningOrange;
      case DocumentStatus.failed:
        return AppTheme.errorRed;
      default:
        return AppTheme.cardBorderColor;
    }
  }

  String _getStatusText(DocumentWithStatus doc) {
    final l10n = context.l10n;

    switch (doc.status) {
      case DocumentStatus.verified:
        return l10n.statusVerified;
      case DocumentStatus.scanned:
        return l10n.statusDocumentsScanned;
      case DocumentStatus.processing:
        return l10n.statusInProgress;
      case DocumentStatus.uploaded:
        return l10n.uploadComplete;
      case DocumentStatus.failed:
        return doc.userDocument?.ocrError ?? l10n.statusRejected;
      case DocumentStatus.notUploaded:
        return l10n.uploadRequired;
    }
  }

  Widget _buildActionButton(DocumentWithStatus doc) {
    if (_isUploading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (doc.isUploaded) {
      return IconButton(
        icon: Icon(Icons.refresh, color: AppTheme.navyPrimary),
        onPressed: () => _uploadDocument(doc.type),
        tooltip: context.l10n.replace,
      );
    }

    return IconButton(
      icon: Icon(Icons.add_circle, color: AppTheme.navyPrimary),
      onPressed: () => _uploadDocument(doc.type),
      tooltip: context.l10n.upload,
    );
  }

  Future<void> _uploadDocument(DocumentType type) async {
    final l10n = context.l10n;

    // Show picker options
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.useCamera),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.uploadImage),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (type.acceptsMimeType('application/pdf'))
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(l10n.uploadPdf),
                onTap: () => Navigator.pop(context, 'pdf'),
              ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    setState(() => _isUploading = true);

    try {
      List<int>? fileBytes;
      String? fileName;
      String? mimeType;

      if (choice == 'camera' || choice == 'gallery') {
        final picker = ImagePicker();
        final source = choice == 'camera' ? ImageSource.camera : ImageSource.gallery;
        final image = await picker.pickImage(source: source, maxWidth: 2000, imageQuality: 85);
        if (image != null) {
          fileBytes = await image.readAsBytes();
          fileName = image.name;
          mimeType = 'image/jpeg';
        }
      } else if (choice == 'pdf') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result != null && result.files.single.bytes != null) {
          fileBytes = result.files.single.bytes!;
          fileName = result.files.single.name;
          mimeType = 'application/pdf';
        }
      }

      if (fileBytes != null && fileName != null && mimeType != null) {
        final repository = ref.read(documentRepositoryProvider);

        // Generate storage path
        final storagePath = repository.generateStoragePath(type.code, fileName);

        // Upload to storage
        await repository.uploadFile(
          path: storagePath,
          fileBytes: fileBytes,
          mimeType: mimeType,
        );

        // Create document record and trigger OCR
        await repository.uploadDocument(
          documentTypeId: type.id,
          storagePath: storagePath,
          originalFilename: fileName,
          fileSizeBytes: fileBytes.length,
          mimeType: mimeType,
          documentTypeCode: type.code, // Triggers OCR processing
        );

        // Refresh documents
        ref.invalidate(userDocumentsProvider);
        ref.invalidate(ds160DocumentsWithStatusProvider);
        ref.invalidate(ds260DocumentsWithStatusProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.uploadSuccess),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.uploadError}: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showDocumentPreview(DocumentWithStatus doc) {
    // TODO: Implement document preview
  }
}
