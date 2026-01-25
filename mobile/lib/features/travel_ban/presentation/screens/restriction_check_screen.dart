import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../visa/data/models/visa_category.dart';
import '../../../visa/presentation/providers/visa_providers.dart';
import '../../data/models/country_restriction.dart';
import '../providers/travel_ban_providers.dart';
import '../widgets/travel_ban_warning_card.dart';

/// Pantalla de verificación de restricciones de viaje
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
    final theme = Theme.of(context);
    final restrictedCountries = ref.watch(allRestrictedCountriesProvider);
    final categories = ref.watch(visaCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Restriction Check'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.travel_explore,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check Your Eligibility',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Verify if your nationality has any visa restrictions',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
              'Your Nationality',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildCountryDropdown(context, restrictedCountries),

            const SizedBox(height: 20),

            // Visa Category Selector
            Text(
              'Visa Category',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildCategoryDropdown(context, categories),

            const SizedBox(height: 32),

            // Check Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _canCheck ? _performCheck : null,
                icon: const Icon(Icons.search),
                label: const Text('Check Restrictions'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
            _buildStatsSection(restrictedCountries),
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
  ) {
    // In a real app, this would be a full country list
    // For now, we'll show restricted countries prominently
    return DropdownButtonFormField<String>(
      value: _selectedCountryCode,
      decoration: InputDecoration(
        hintText: 'Select your country',
        prefixIcon: const Icon(Icons.flag_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
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
        child: Text(name),
      ));
    }

    return items;
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    AsyncValue<List<VisaCategory>> categories,
  ) {
    return categories.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (cats) => DropdownButtonFormField<String>(
        value: _selectedCategoryCode,
        decoration: InputDecoration(
          hintText: 'Select visa category',
          prefixIcon: const Icon(Icons.badge_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        items: cats.map((cat) {
          return DropdownMenuItem(
            value: cat.code,
            child: Text('${cat.code} - ${cat.name}'),
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

  Widget _buildStatsSection(AsyncValue<List<CountryRestriction>> restrictedCountries) {
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
              'Current Restrictions (2026)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Total Ban', totalBan, Colors.red),
                const SizedBox(width: 8),
                _buildStatCard('Partial', partial, Colors.orange),
                const SizedBox(width: 8),
                _buildStatCard('Paused', pause, Colors.amber),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
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
