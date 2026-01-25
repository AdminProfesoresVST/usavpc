import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/visa_category.dart';
import '../../data/models/prerequisite_form.dart';
import '../providers/visa_providers.dart';
import '../widgets/document_check_card.dart';

/// Pantalla de verificación de prerrequisitos
class PrerequisiteCheckerScreen extends ConsumerStatefulWidget {
  final String visaCategoryCode;

  const PrerequisiteCheckerScreen({
    super.key,
    required this.visaCategoryCode,
  });

  @override
  ConsumerState<PrerequisiteCheckerScreen> createState() => _PrerequisiteCheckerScreenState();
}

class _PrerequisiteCheckerScreenState extends ConsumerState<PrerequisiteCheckerScreen> {
  final Map<String, bool> _documentStatus = {};
  final Map<String, Map<String, dynamic>> _extractedData = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final prerequisitesAsync = ref.watch(prerequisiteFormsProvider(widget.visaCategoryCode));
    final categoryAsync = ref.watch(visaCategoryByCodeProvider(widget.visaCategoryCode));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Checklist'),
        centerTitle: true,
      ),
      body: prerequisitesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (prerequisites) {
          if (prerequisites.isEmpty) {
            return _buildNoPrerequisitesView(context);
          }

          return Column(
            children: [
              // Header with progress
              categoryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (category) => _buildHeader(context, category, prerequisites),
              ),

              // List of prerequisites
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: prerequisites.length,
                  itemBuilder: (context, index) {
                    final form = prerequisites[index];
                    return DocumentCheckCard(
                      form: form,
                      validation: null, // Would come from provider
                      onHasDocumentChanged: (hasDoc) {
                        setState(() {
                          _documentStatus[form.id] = hasDoc;
                        });
                      },
                      onDataExtracted: (data) {
                        setState(() {
                          _extractedData[form.id] = data;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: prerequisitesAsync.when(
        loading: () => null,
        error: (_, __) => null,
        data: (prerequisites) => _buildBottomBar(context, prerequisites),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    VisaCategory? category,
    List<PrerequisiteForm> prerequisites,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final completedCount = _documentStatus.values.where((v) => v).length;
    final totalRequired = prerequisites.where((p) => p.isMandatory).length;
    final progress = totalRequired > 0 ? completedCount / totalRequired : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.tertiaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  color: colorScheme.tertiary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category != null
                          ? '${category.code} - ${category.name}'
                          : widget.visaCategoryCode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (category != null)
                      Text(
                        'Form: ${category.formEngine.value}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Progress bar
          Row(
            children: [
              Text(
                'Progress',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount of $totalRequired required',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colorScheme.tertiary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPrerequisitesView(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Prerequisites Required',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This visa category does not require any prerequisite documents. '
              'You can proceed directly to fill out the application form.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // Navigate to form
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue to Application'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, List<PrerequisiteForm> prerequisites) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final mandatoryForms = prerequisites.where((p) => p.isMandatory).toList();
    final allMandatoryComplete = mandatoryForms.every(
      (form) => _documentStatus[form.id] == true,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: allMandatoryComplete
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allMandatoryComplete
                        ? Icons.check_circle
                        : Icons.pending,
                    size: 18,
                    color: allMandatoryComplete ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    allMandatoryComplete
                        ? 'All required documents verified'
                        : 'Missing required documents',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          allMandatoryComplete ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: allMandatoryComplete ? _continueToApplication : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continue to Application'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continueToApplication() {
    // Navigate to DS-160 or DS-260 form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All prerequisites verified. Proceeding to application...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
