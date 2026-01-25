import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/theme/app_theme.dart';

import '../../../visa/data/models/visa_category.dart';
import '../../../visa/presentation/providers/visa_providers.dart';
import '../../data/models/country_restriction.dart';
import '../providers/travel_ban_providers.dart';
import '../widgets/travel_ban_warning_card.dart';

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
    final theme = Theme.of(context);
    final restrictedCountries = ref.watch(allRestrictedCountriesProvider);
    final categories = ref.watch(visaCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(l10n.travelBanTitle),
        centerTitle: true,
        backgroundColor: AppTheme.navyPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Standard Navy Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.navyPrimary,
                borderRadius: AppTheme.cardRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navyPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.travel_explore,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.checkYourEligibility,
                          style: AppTheme.h1WhiteBold,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.checkYourEligibilitySubtitle,
                          style: AppTheme.bodyWhiteRegular.copyWith(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Country Selector
            Text(
              l10n.yourNationality,
              style: AppTheme.h2NavyBold,
            ),
            const SizedBox(height: 8),
            _buildCountryDropdown(context, restrictedCountries, l10n),

            const SizedBox(height: 20),

            // Visa Category Selector
            Text(
              l10n.visaCategory,
              style: AppTheme.h2NavyBold,
            ),
            const SizedBox(height: 8),
            _buildCategoryDropdown(context, categories, l10n),

            const SizedBox(height: 32),

            // Check Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _canCheck ? _performCheck : null,
                icon: const Icon(Icons.search),
                label: Text(l10n.checkRestrictions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navyPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.inputRadius,
                  ),
                  textStyle: AppTheme.h2WhiteBold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Result
            if (_selectedCountryCode != null &&
                _selectedCategoryCode != null &&
                _selectedFormEngine != null)
              _buildResultSection(),

            const SizedBox(height: 32),

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
        fillColor: Colors.white,
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
      error: (e, _) => Text('Error: $e'),
      data: (cats) => DropdownButtonFormField<String>(
        value: _selectedCategoryCode,
        isExpanded: true, // Fixes overflow
        decoration: InputDecoration(
          hintText: l10n.selectCategory,
          prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.navyPrimary),
          filled: true,
          fillColor: Colors.white,
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
      error: (e, _) => Text('Error: $e'),
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
            const SizedBox(height: 12),
            Row(
              children: [
                  _buildStatCard(l10n.totalBan, totalBan.toString(), Colors.red, Colors.red.shade50),
                  _buildStatCard(l10n.partial, partial.toString(), Colors.orange, Colors.orange.shade50),
                  _buildStatCard(l10n.paused, pause.toString(), Colors.grey, Colors.grey.shade200),
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.inputRadius,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color, // Keep number colored
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTheme.captionGreyRegular.copyWith(
                fontSize: 10,
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
