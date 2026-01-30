import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';

import 'package:mobile/models/visa_category.dart';
import 'package:mobile/providers/visa_providers.dart';
import 'package:mobile/models/country_restriction.dart';
import 'package:mobile/providers/travel_ban_providers.dart';
import 'package:mobile/widgets/travel_ban_warning_card.dart';

class RestrictionCheckScreen extends ConsumerStatefulWidget {
  const RestrictionCheckScreen({super.key});

  @override
  ConsumerState<RestrictionCheckScreen> createState() => _RestrictionCheckScreenState();
}

class _RestrictionCheckScreenState extends ConsumerState<RestrictionCheckScreen> {
  String? _selectedCountryCode;
  String? _selectedCategoryCode;
  FormEngine? _selectedFormEngine;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final restrictedCountries = ref.watch(allRestrictedCountriesProvider);
    final categories = ref.watch(visaCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(l10n.travelBanTitle),
        centerTitle: true,
        backgroundColor: AppTheme.navyPrimary,
        foregroundColor: AppTheme.inkInverse,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.paddingEstandar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Standard Navy Card
            Container(
              padding: AppTheme.paddingMedio,
              decoration: BoxDecoration(
                color: AppTheme.navyPrimary,
                borderRadius: AppTheme.cardRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navyPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: AppTheme.paddingPequeno,
                    decoration: BoxDecoration(
                      color: AppTheme.inkInverse.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.travel_explore,
                      color: AppTheme.inkInverse,
                      size: AppTheme.iconoMediano,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingTarjetas),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.checkYourEligibility,
                          style: AppTheme.h1WhiteBold,
                        ),
                        SizedBox(height: AppTheme.espacioEntreLabelInput),
                        Text(
                          l10n.checkYourEligibilitySubtitle,
                          style: AppTheme.bodyWhiteRegular.copyWith(fontSize: AppTheme.fuenteLabel, color: AppTheme.inkInverse70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.espacioEntreCards),

            // Country Selector
            Text(
              l10n.yourNationality,
              style: AppTheme.h2NavyBold,
            ),
            SizedBox(height: AppTheme.espacioEntreCampos),
            _buildCountryDropdown(context, restrictedCountries, l10n),

            SizedBox(height: AppTheme.espacioEntreCards),

            // Visa Category Selector
            Text(
              l10n.visaCategory,
              style: AppTheme.h2NavyBold,
            ),
            SizedBox(height: AppTheme.espacioEntreCampos),
            _buildCategoryDropdown(context, categories, l10n),

            SizedBox(height: AppTheme.espacioEntreBloques),

            // Check Button
            SizedBox(
              width: double.infinity,
              height: AppTheme.alturaBotonGrande,
              child: ElevatedButton.icon(
                onPressed: _canCheck ? _performCheck : null,
                icon: const Icon(Icons.search),
                label: Text(l10n.checkRestrictions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: AppTheme.inkInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.inputRadius,
                  ),
                  textStyle: AppTheme.h2WhiteBold,
                ),
              ),
            ),

            SizedBox(height: AppTheme.espacioEntreCards),

            // Result
            if (_selectedCountryCode != null &&
                _selectedCategoryCode != null &&
                _selectedFormEngine != null)
              _buildResultSection(),

            SizedBox(height: AppTheme.espacioEntreBloques),

            // Statistics
            _buildStatsSection(restrictedCountries, l10n),
          ],
        ),
      ),
    );
  }

  bool get _canCheck =>
      _selectedCountryCode != null &&
      _selectedCategoryCode != null &&
      _selectedFormEngine != null;

  Widget _buildCountryDropdown(
    BuildContext context,
    AsyncValue<List<CountryRestriction>> restrictedCountries,
    dynamic l10n,
  ) {
    return DropdownButtonFormField<String>(
      value: _selectedCountryCode,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: l10n.selectCountry,
        prefixIcon: const Icon(Icons.flag_outlined, color: AppTheme.navyPrimary),
        filled: true,
        fillColor: AppTheme.inkInverse,
        border: OutlineInputBorder(borderRadius: AppTheme.inputRadius),
      ),
      items: _buildCountryItems(restrictedCountries),
      onChanged: (value) {
        setState(() {
          _selectedCountryCode = value;
        });
      },
    );
  }

  List<DropdownMenuItem<String>> _buildCountryItems(
    AsyncValue<List<CountryRestriction>> restrictedCountries,
  ) {
    final items = <DropdownMenuItem<String>>[];
    
    // Common countries first
    final commonCountries = [
      ('MX', 'Mexico'),
      ('CO', 'Colombia'),
      ('BR', 'Brazil'),
      ('IN', 'India'),
      ('CN', 'China'),
      ('PH', 'Philippines'),
      ('VE', 'Venezuela'),
      ('CU', 'Cuba'),
    ];

    for (final (code, name) in commonCountries) {
      items.add(DropdownMenuItem(
        value: code,
        child: Text(name, overflow: TextOverflow.ellipsis),
      ));
    }

    return items;
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    AsyncValue<List<VisaCategory>> categories,
    dynamic l10n,
  ) {
    return categories.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(l10n.error(e.toString())),
      data: (cats) => DropdownButtonFormField<String>(
        value: _selectedCategoryCode,
        isExpanded: true, // Fixes overflow
        decoration: InputDecoration(
          hintText: l10n.selectCategory,
          prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.navyPrimary),
          filled: true,
          fillColor: AppTheme.inkInverse,
          border: OutlineInputBorder(borderRadius: AppTheme.inputRadius),
        ),
        items: cats.map((cat) {
          return DropdownMenuItem(
            value: cat.code,
            child: Text('${cat.code} - ${cat.name}', overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            final category = cats.firstWhere((c) => c.code == value);
            setState(() {
              _selectedCategoryCode = value;
              _selectedFormEngine = category.formEngine;
            });
          }
        },
      ),
    );
  }

  Widget _buildResultSection() {
    final params = RestrictionCheckParams(
      countryCode: _selectedCountryCode!,
      visaCategoryCode: _selectedCategoryCode!,
      formEngine: _selectedFormEngine!,
    );

    final result = ref.watch(restrictionCheckProvider(params));

    return result.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(context.l10n.error(e.toString())),
      data: (checkResult) => TravelBanWarningCard(
        result: checkResult,
        onLearnMore: () {
          // Navigate to more info
        },
      ),
    );
  }

  Widget _buildStatsSection(AsyncValue<List<CountryRestriction>> restrictedCountries, dynamic l10n) {
    return restrictedCountries.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (countries) {
        final totalBan = countries.where((c) => c.restrictionLevel == RestrictionLevel.totalBan).length;
        final partial = countries.where((c) => c.restrictionLevel == RestrictionLevel.partialRestriction).length;
        final pause = countries.where((c) => c.restrictionLevel == RestrictionLevel.immigrantPause).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentRestrictions,
              style: AppTheme.h2NavyBold,
            ),
            SizedBox(height: AppTheme.espacioEntreGrupos),
            Row(
              children: [
                  _buildStatCard(l10n.totalBan, totalBan.toString(), AppTheme.errorRed, AppTheme.errorRedLight),
                  _buildStatCard(l10n.partial, partial.toString(), AppTheme.warningOrange, AppTheme.warningOrangeLight),
                  _buildStatCard(l10n.paused, pause.toString(), AppTheme.dividerGrey, AppTheme.cardBorderColor),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        margin: AppTheme.paddingCompacto,
        padding: AppTheme.paddingEstandar,
        decoration: BoxDecoration(
          color: AppTheme.inkInverse,
          borderRadius: AppTheme.inputRadius,
          border: Border.all(color: AppTheme.cardBorderColor),
          boxShadow: [
            BoxShadow(
              color: AppTheme.inkPrimary.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.h1NavyBold.copyWith(color: color),
            ),
            SizedBox(height: AppTheme.espacioEntreLabelInput),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.captionGreyRegular.copyWith(
                fontSize: AppTheme.fuenteCaption,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _performCheck() {
    // Trigger rebuild with current selections
    setState(() {});
  }
}
