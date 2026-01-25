import 'package:flutter/material.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/visa_localization.dart';

import '../../data/models/prerequisite_form.dart';

/// Tarjeta de verificación de documento prerrequisito
class DocumentCheckCard extends StatefulWidget {
  final PrerequisiteForm form;
  final PrerequisiteValidation? validation;
  final ValueChanged<bool> onHasDocumentChanged;
  final ValueChanged<Map<String, dynamic>>? onDataExtracted;

  const DocumentCheckCard({
    super.key,
    required this.form,
    this.validation,
    required this.onHasDocumentChanged,
    this.onDataExtracted,
  });

  @override
  State<DocumentCheckCard> createState() => _DocumentCheckCardState();
}

class _DocumentCheckCardState extends State<DocumentCheckCard> {
  bool _hasDocument = false;
  bool _isExpanded = false;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _hasDocument = widget.validation?.hasDocument ?? false;
    
    // Initialize controllers for critical fields
    for (final field in widget.form.requiredFields) {
      final existingValue = widget.validation?.extractedData?[field] as String?;
      _controllers[field] = TextEditingController(text: existingValue);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    
    final statusColor = _getStatusColor(widget.validation?.validationStatus);
    final statusIcon = _getStatusIcon(widget.validation?.validationStatus);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: AppTheme.standardCardDecoration.copyWith(
        border: Border.all(
          color: _isExpanded ? statusColor.withOpacity(0.5) : AppTheme.cardBorderColor,
          width: _isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  
                  // Form info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.form.formCode,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (widget.form.isMandatory)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: AppTheme.smallRadius,
                                ),
                                child: Text(
                                  l10n.required,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: AppTheme.smallRadius,
                                ),
                                child: Text(
                                  l10n.optional,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.form.formName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Expand icon
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(context, l10n),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, dynamic l10n) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          
          // Help text
          if (widget.form.helpText != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: AppTheme.buttonRadius,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.form.helpText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Do you have this document?
          Text(
            l10n.doYouHaveDocument,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  context,
                  l10n.yesHaveIt,
                  Icons.check_circle_outline,
                  _hasDocument,
                  () => _setHasDocument(true),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOptionButton(
                  context,
                  l10n.noNotYet,
                  Icons.cancel_outlined,
                  !_hasDocument,
                  () => _setHasDocument(false),
                  Colors.red,
                ),
              ),
            ],
          ),
          
          // Data extraction form if has document
          if (_hasDocument) ...[
            const SizedBox(height: 20),
            Text(
              l10n.enterDocDetails,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: widget.form.requiredFields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _controllers[field],
                      decoration: AppTheme.inputDecoration(
                        labelText: _formatFieldName(field),
                        hintText: _getFieldHint(field),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fieldRequired;
                        }
                        return _validateFieldFormat(field, value, l10n);
                      },
                      onChanged: (_) => _onDataChanged(),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _saveData(l10n),
                icon: const Icon(Icons.save),
                label: Text(l10n.saveDocInfo),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.inputRadius,
                  ),
                ),
              ),
            ),
          ],
          
          // Issued by info
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.business,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.issuedBy}: ${VisaLocalization.getIssuedBy(widget.form.issuedBy, l10n)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.inputRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: AppTheme.inputRadius,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setHasDocument(bool value) {
    setState(() {
      _hasDocument = value;
    });
    widget.onHasDocumentChanged(value);
  }

  void _onDataChanged() {
    // Collect all data
    final data = <String, dynamic>{};
    for (final entry in _controllers.entries) {
      data[entry.key] = entry.value.text;
    }
    widget.onDataExtracted?.call(data);
  }

  void _saveData(dynamic l10n) {
    if (_formKey.currentState?.validate() ?? false) {
      _onDataChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.docInfoSaved),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _getStatusColor(PrerequisiteStatus? status) {
    switch (status) {
      case PrerequisiteStatus.valid:
        return Colors.green;
      case PrerequisiteStatus.incomplete:
        return Colors.orange;
      case PrerequisiteStatus.blocked:
        return Colors.red;
      case PrerequisiteStatus.pending:
      case PrerequisiteStatus.skipped:
      case PrerequisiteStatus.notApplicable:
      case null:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PrerequisiteStatus? status) {
    switch (status) {
      case PrerequisiteStatus.valid:
        return Icons.check_circle;
      case PrerequisiteStatus.incomplete:
        return Icons.warning;
      case PrerequisiteStatus.blocked:
        return Icons.block;
      case PrerequisiteStatus.pending:
      case PrerequisiteStatus.skipped:
      case PrerequisiteStatus.notApplicable:
      case null:
        return Icons.help_outline;
    }
  }

  String _formatFieldName(String field) {
    return field
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getFieldHint(String field) {
    switch (field) {
      case 'sevis_id':
        return 'N0012345678';
      case 'school_code':
        return 'ABC12345678';
      case 'program_number':
        return 'P-1-01234';
      case 'receipt_number':
        return 'WAC2012345678';
      case 'nvc_case_number':
        return 'MSCXXXX1234567';
      default:
        return '';
    }
  }

  String? _validateFieldFormat(String field, String value, dynamic l10n) {
    switch (field) {
      case 'sevis_id':
        if (!value.startsWith('N') || value.length != 11) {
          return l10n.invalidFormat; // Generic error for format mismatch
        }
        break;
      case 'receipt_number':
        if (!RegExp(r'^(WAC|LIN|EAC|SRC|IOE)').hasMatch(value)) {
           return l10n.invalidFormat;
        }
        break;
      case 'program_number':
        if (!value.startsWith('P-1-')) {
           return l10n.invalidFormat;
        }
        break;
    }
    return null;
  }
}
