import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/visa_category.dart';
import '../providers/visa_providers.dart';

/// Pantalla de selección de tipo de visa
class VisaCategorySelectorScreen extends ConsumerWidget {
  const VisaCategorySelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedFormEngine = ref.watch(selectedFormEngineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Visa Type'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Form Engine Tabs
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFormTab(
                    context,
                    ref,
                    FormEngine.ds160,
                    'Non-Immigrant',
                    Icons.flight_takeoff,
                    selectedFormEngine == FormEngine.ds160,
                  ),
                ),
                Expanded(
                  child: _buildFormTab(
                    context,
                    ref,
                    FormEngine.ds260,
                    'Immigrant',
                    Icons.home,
                    selectedFormEngine == FormEngine.ds260,
                  ),
                ),
              ],
            ),
          ),

          // Category List
          Expanded(
            child: _buildCategoryList(context, ref, selectedFormEngine),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTab(
    BuildContext context,
    WidgetRef ref,
    FormEngine engine,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        ref.read(selectedFormEngineProvider.notifier).state = engine;
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  engine.value,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary.withOpacity(0.7)
                        : colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    WidgetRef ref,
    FormEngine? selectedEngine,
  ) {
    if (selectedEngine == null) {
      return const Center(
        child: Text('Select a visa type above'),
      );
    }

    final categoriesAsync = selectedEngine == FormEngine.ds160
        ? ref.watch(nonImmigrantCategoriesProvider)
        : ref.watch(immigrantCategoriesProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (categories) {
        // Group categories by fee tier
        final grouped = _groupByFee(categories);

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final entry = grouped.entries.elementAt(index);
            return _buildFeeGroup(context, ref, entry.key, entry.value);
          },
        );
      },
    );
  }

  Map<int, List<VisaCategory>> _groupByFee(List<VisaCategory> categories) {
    final grouped = <int, List<VisaCategory>>{};
    for (final cat in categories) {
      grouped.putIfAbsent(cat.baseFeeUsd, () => []).add(cat);
    }
    // Sort by fee descending
    final sorted = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
    return sorted;
  }

  Widget _buildFeeGroup(
    BuildContext context,
    WidgetRef ref,
    int fee,
    List<VisaCategory> categories,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '\$$fee MRV Fee',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const Expanded(child: Divider(indent: 12)),
            ],
          ),
        ),
        ...categories.map((cat) => _buildCategoryCard(context, ref, cat)),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    VisaCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          ref.read(selectedVisaCategoryProvider.notifier).state = category;
          // Navigate to prerequisite checker
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrerequisiteCheckerScreen(
                visaCategoryCode: category.code,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Code badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    category.code,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(category),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (category.description != null)
                      Text(
                        category.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (category.requiresSevis)
                          _buildBadge('SEVIS', Colors.teal),
                        if (category.requiresPetition)
                          _buildBadge('Petition', Colors.purple),
                        if (category.isFianceVisa)
                          _buildBadge('K Visa', Colors.pink),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getCategoryColor(VisaCategory category) {
    if (category.type.isImmigrant) {
      return Colors.green;
    }
    if (category.requiresPetition) {
      return Colors.purple;
    }
    if (category.requiresSevis) {
      return Colors.teal;
    }
    return Colors.blue;
  }
}

// Re-import for navigation
import 'prerequisite_checker_screen.dart';
