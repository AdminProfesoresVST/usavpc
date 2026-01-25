import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/visa_localization.dart';
import 'package:mobile/core/widgets/standard_service_card.dart';

import '../../data/models/visa_category.dart';
import '../providers/visa_providers.dart';
import 'prerequisite_checker_screen.dart';

/// Pantalla de selección de tipo de visa
class VisaCategorySelectorScreen extends ConsumerWidget {
  const VisaCategorySelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedFormEngine = ref.watch(selectedFormEngineProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(l10n.selectVisaType),
        centerTitle: true,
        backgroundColor: AppTheme.navyPrimary,
        foregroundColor: AppTheme.inkInverse,
      ),
      body: Column(
        children: [
          // Form Engine Tabs
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: AppTheme.cardRadius,
              border: Border.all(color: AppTheme.dividerGrey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildFormTab(
                    context,
                    ref,
                    FormEngine.ds160,
                    l10n.nonImmigrant,
                    Icons.flight_takeoff,
                    selectedFormEngine == FormEngine.ds160,
                  ),
                ),
                Expanded(
                  child: _buildFormTab(
                    context,
                    ref,
                    FormEngine.ds260,
                    l10n.immigrant,
                    Icons.home,
                    selectedFormEngine == FormEngine.ds260,
                  ),
                ),
              ],
            ),
          ),

          // Category List
          Expanded(
            child: _buildCategoryList(context, ref, selectedFormEngine, l10n),
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
    return InkWell(
      onTap: () {
        ref.read(selectedFormEngineProvider.notifier).set(engine);
      },
      borderRadius: AppTheme.cardRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.navyPrimary : AppTheme.surfaceWhite,
          borderRadius: AppTheme.inputRadius, // Slightly less than container (16-2)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.inkInverse : AppTheme.navyPrimary.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Text(
                  label,
                  style: isSelected
                      ? AppTheme.h2NavyBold.copyWith(color: AppTheme.inkInverse, fontWeight: FontWeight.bold)
                      : AppTheme.h2NavyBold.copyWith(color: AppTheme.navyPrimary.withOpacity(0.6)),
                ),
                Text(
                  engine.value,
                  style: (isSelected
                          ? AppTheme.captionWhiteRegular
                          : AppTheme.captionGreyRegular)
                      .copyWith(fontSize: 10),
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
    dynamic l10n,
  ) {
    if (selectedEngine == null) {
      return Center(
        child: Text(l10n.selectVisaType),
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
            return _buildFeeGroup(context, ref, entry.key, entry.value, l10n);
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
    dynamic l10n,
  ) {
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
                  color: AppTheme.navyPrimary,
                  borderRadius: AppTheme.cardRadius,
                ),
                child: Text(
                  '\$$fee ${l10n.mrvFee}',
                  style: AppTheme.captionWhiteBold,
                ),
              ),
              const Expanded(child: Divider(indent: 12)),
            ],
          ),
        ),
        ...categories.map((cat) => _buildCategoryCard(context, ref, cat, l10n)),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    VisaCategory category,
    dynamic l10n,
  ) {
    // Determine badge
    String? badgeText;
    Color? badgeColor;
    Color? badgeBg;

    if (category.requiresSevis) {
      badgeText = l10n.sevis;
      badgeColor = AppTheme.infoBlue;
      badgeBg = AppTheme.infoBlueLight;
    } else if (category.requiresPetition) {
      badgeText = l10n.petition;
      badgeColor = AppTheme.warningOrange;
      badgeBg = AppTheme.warningOrangeLight;
    } else if (category.isFianceVisa) {
      badgeText = l10n.kVisa;
      badgeColor = AppTheme.errorRed;
      badgeBg = AppTheme.errorRedLight;
    }

    // Custom "Code Badge" for the icon slot
    final codeBadge = Container(
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.navyPrimary.withOpacity(0.08),
        borderRadius: AppTheme.buttonRadius,
      ),
      child: Center(
        child: Text(
          category.code,
          style: AppTheme.h2NavyBold,
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: StandardServiceCard(
        title: VisaLocalization.getVisaName(category.code, category.name, l10n),
        description: category.description,
        onTap: () {
          ref.read(selectedVisaCategoryProvider.notifier).set(category);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrerequisiteCheckerScreen(
                visaCategoryCode: category.code,
              ),
            ),
          );
        },
        customBadge: codeBadge, // Instead of Icon
        badgeText: badgeText,
        badgeColor: badgeColor,
        badgeBg: badgeBg,
        // icon: null, // We act as if customBadge is the icon replacement in logic
      ),
    );
  }
}
