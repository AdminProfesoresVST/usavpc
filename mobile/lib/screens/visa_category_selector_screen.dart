import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/utils/visa_localization.dart';
import 'package:mobile/core/widgets/standard_service_card.dart';

import 'package:mobile/models/visa_category.dart';
import 'package:mobile/providers/visa_providers.dart';
import 'prerequisite_checker_screen.dart';

/// Pantalla de selección de tipo de visa
class VisaCategorySelectorScreen extends ConsumerWidget {
  const VisaCategorySelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
            margin: AppTheme.paddingEstandar,
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
        padding: AppTheme.paddingPequeno,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.navyPrimary : AppTheme.surfaceWhite,
          borderRadius: AppTheme.inputRadius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.inkInverse : AppTheme.navyPrimary.withValues(alpha: 0.6),
              size: AppTheme.iconoEnTarjeta,
            ),
            const SizedBox(width: AppTheme.espacioEntreLabelInput),
            Column(
              children: [
                Text(
                  label,
                  style: isSelected
                      ? AppTheme.h2NavyBold.copyWith(color: AppTheme.inkInverse, fontWeight: FontWeight.bold)
                      : AppTheme.h2NavyBold.copyWith(color: AppTheme.navyPrimary.withValues(alpha: 0.6)),
                ),
                Text(
                  engine.value,
                  style: (isSelected
                          ? AppTheme.captionWhiteRegular
                          : AppTheme.captionGreyRegular)
                      .copyWith(fontSize: AppTheme.fuenteCaption),
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
      error: (e, _) => Center(child: Text(l10n.error(e.toString()))),
      data: (categories) {
        // Group categories by fee tier
        final grouped = _groupByFee(categories);

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(AppTheme.marginPantalla, 0, AppTheme.marginPantalla, 100),
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
    
    // [UX-AUDIT] Sort groups by Fee ASCENDING ($185 Tourist first, not $205 Petition)
    // Then sort items within groups by Popularity
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // Ascending Fee

    for (var entry in sortedEntries) {
      entry.value.sort((a, b) {
        final popA = _getPopularityScore(a.code);
        final popB = _getPopularityScore(b.code);
        if (popA != popB) return popB.compareTo(popA); // Higher popularity first
        return a.name.compareTo(b.name); // Alphabetical fallback
      });
    }

    return Map.fromEntries(sortedEntries);
  }

  int _getPopularityScore(String code) {
    // [UX-AUDIT] Hardcoded popularity for sort order
    switch (code) {
      case 'B1/B2': return 100; // Tourist - Most Popular
      case 'F1': return 90;     // Student
      case 'J1': return 80;     // Exchange
      case 'H1B': return 70;    // Work (Specialty)
      case 'H2A': return 65;    // Work (Agri)
      case 'H2B': return 60;    // Work (Non-Agri)
      default: return 0;
    }
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
          padding: AppTheme.paddingListItem,
          child: Row(
            children: [
              Container(
                padding: AppTheme.paddingPequeno,
                decoration: BoxDecoration(
                  color: AppTheme.navyPrimary,
                  borderRadius: AppTheme.cardRadius,
                ),
                child: Text(
                  '\$$fee ${l10n.mrvFee}',
                  style: AppTheme.captionWhiteBold,
                ),
              ),
              // [UX-AUDIT] Removed Divider per user request
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

    // [UX-AUDIT] Highlighting Popular Options
    final isRecommended = ['B1/B2', 'CR1', 'IR1'].contains(category.code);

    if (isRecommended) {
      badgeText = 'Más Solicitada'; // Most Requested
      badgeColor = AppTheme.navyPrimary;
      badgeBg = AppTheme.accentGold; // Using distinct gold for recommendation
    } else if (category.requiresSevis) {
      badgeText = l10n.sevis;
      badgeColor = AppTheme.infoBlue;
      badgeBg = AppTheme.infoBlueLight;
    } else if (category.requiresPetition) {
      badgeText = l10n.petition;
      badgeColor = AppTheme.inkSecondary; // Mapped from Orange
      badgeBg = AppTheme.dividerGreyLight;
    } else if (category.isFianceVisa) {
      badgeText = l10n.kVisa;
      badgeColor = AppTheme.navyPrimary; // Mapped from Red
      badgeBg = AppTheme.softBlue;
    }

    // Custom "Code Badge" for the icon slot
    final codeBadge = Container(
      constraints: BoxConstraints(minWidth: AppTheme.espacioAntesBotonPrincipal, minHeight: AppTheme.espacioAntesBotonPrincipal),
      padding: AppTheme.paddingCompacto,
      decoration: BoxDecoration(
        color: isRecommended ? AppTheme.navyPrimary : AppTheme.navyPrimary.withValues(alpha: 0.08),
        borderRadius: AppTheme.buttonRadius,
      ),
      child: Center(
        child: Text(
          category.code,
          style: isRecommended ? AppTheme.h2WhiteBold : AppTheme.h2NavyBold,
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.espacioEntreCampos),
      child: Container(
        decoration: isRecommended ? BoxDecoration(
          borderRadius: AppTheme.cardRadius,
          border: Border.all(color: AppTheme.accentGold, width: 2), // Highlight border
          color: AppTheme.softBlue.withValues(alpha: 0.3),
        ) : null,
        child: StandardServiceCard(
          title: VisaLocalization.getVisaName(category.code, category.name, l10n),
          description: VisaLocalization.getVisaDescription(category.code, category.description ?? '', l10n),
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
          customBadge: codeBadge, 
          badgeText: badgeText,
          badgeColor: badgeColor,
          badgeBg: badgeBg,
        ),
      ),
    );
  }
}
