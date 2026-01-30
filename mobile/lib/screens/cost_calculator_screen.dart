import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/core/extensions/build_context_extensions.dart'; // Ensure l10n access
import 'package:mobile/core/theme/app_theme.dart';

import 'package:mobile/models/visa_category.dart';
import 'package:mobile/providers/visa_providers.dart';
import 'package:mobile/providers/cost_calculator_providers.dart';
import '../widgets/cost_breakdown_card.dart';
import 'package:mobile/core/utils/visa_localization.dart';

class CostCalculatorScreen extends ConsumerStatefulWidget {
  const CostCalculatorScreen({super.key});

  @override
  ConsumerState<CostCalculatorScreen> createState() => _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends ConsumerState<CostCalculatorScreen> {
  String? _selectedCountryCode;
  VisaCategory? _selectedCategory;
  bool _crossingByLand = false;
  bool _isRoundTrip = true;
  bool _isFlight = false;
  bool _calculationRequested = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = ref.watch(visaCategoriesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(l10n.costCalculatorTitle),
        centerTitle: true,
        backgroundColor: AppTheme.navyPrimary,
        foregroundColor: AppTheme.inkInverse,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showFeesInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppTheme.paddingEstandar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card - Standard Navy Card
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
                      Icons.calculate_outlined,
                      color: AppTheme.inkInverse,
                      size: AppTheme.iconoNavegacion,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingTarjetas),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isRoundTrip ? l10n.roundTrip : l10n.oneWay,
                          style: AppTheme.captionGreyRegular,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isRoundTrip,
                    onChanged: (val) => setState(() => _isRoundTrip = val),
                    activeColor: AppTheme.actionBlue,
                  ),
                ],
              ),
            ),
          SizedBox(height: AppTheme.espacioEntreSecciones),
          // Crossing Type
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.directions_car, color: AppTheme.inkSecondary),
            title: Text(l10n.crossingByLand, style: AppTheme.labelRegular),
            subtitle: Text(l10n.crossingByLandSubtitle, style: AppTheme.captionGreyRegular),
            trailing: Switch(
              value: !_isFlight,
              onChanged: (val) => setState(() => _isFlight = !val),
              activeColor: AppTheme.actionBlue,
            ),
          ),
          
           if (_isFlight) ...[
             SizedBox(height: AppTheme.espacioEntreSecciones),
             Text(
               l10n.flightCostEstimate,
               style: AppTheme.captionGreyRegular,
             ),
             // ... slider ...
          ],
          // ...
          Text(
            l10n.includesHotelCosts,
            style: AppTheme.captionGreyRegular.copyWith(fontSize: AppTheme.fuenteCaption),
          ),   // Visa Category
            Text(
              l10n.visaCategory,
              style: AppTheme.h2NavyBold,
            ),
            SizedBox(height: AppTheme.espacioEntreCampos),
            _buildCategoryDropdown(context, categories, l10n),

            SizedBox(height: AppTheme.espacioEntreCards),

            // Options
            Text(
              l10n.additionalOptions,
              style: AppTheme.h2NavyBold,
            ),
            SizedBox(height: AppTheme.espacioEntreCampos),
            _buildOptionsCard(context, l10n),

            SizedBox(height: AppTheme.espacioEntreCards),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              height: AppTheme.alturaBotonGrande,
              child: ElevatedButton.icon(
                onPressed: _canCalculate ? _calculate : null,
                icon: const Icon(Icons.calculate),
                label: Text(l10n.calculateTotalCost),
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
            if (_calculationRequested && _selectedCategory != null)
              _buildCalculationResult(),

            SizedBox(height: AppTheme.espacioEntreBloques),

            // Fee summary cards
            _buildFeeSummaryCards(context, l10n),
          ],
        ),
      ),
    );
  }

  bool get _canCalculate =>
      _selectedCountryCode != null && _selectedCategory != null;

  Widget _buildCountryDropdown(BuildContext context, dynamic l10n) {
    final countries = [
      ('MX', 'Mexico 🇲🇽'),
      ('CO', 'Colombia 🇨🇴'),
      ('BR', 'Brazil 🇧🇷'),
      ('AR', 'Argentina 🇦🇷'),
      ('IN', 'India 🇮🇳'),
      ('CN', 'China 🇨🇳'),
      ('PH', 'Philippines 🇵🇭'),
      ('VE', 'Venezuela 🇻🇪'),
      ('CL', 'Chile 🇨🇱'),
      ('PE', 'Peru 🇵🇪'),
      ('EC', 'Ecuador 🇪🇨'),
      ('DO', 'Dominican Republic 🇩🇴'),
    ];

    return DropdownButtonFormField<String>(
      value: _selectedCountryCode,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: l10n.selectCountry,
        prefixIcon: const Icon(Icons.public, color: AppTheme.navyPrimary),
        filled: true,
        fillColor: AppTheme.inkInverse,
        border: OutlineInputBorder(borderRadius: AppTheme.inputRadius),
      ),
      items: countries.map((c) {
        return DropdownMenuItem(
          value: c.$1,
          child: Text(c.$2, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCountryCode = value;
          _calculationRequested = false;
        });
      },
    );
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    AsyncValue<List<VisaCategory>> categories,
    dynamic l10n,
  ) {
    return categories.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(l10n.error(e.toString())),
      data: (cats) => DropdownButtonFormField<VisaCategory>(
        value: _selectedCategory,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: l10n.selectCategory,
          prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.navyPrimary),
          filled: true,
          fillColor: AppTheme.inkInverse,
          border: OutlineInputBorder(borderRadius: AppTheme.inputRadius),
        ),
        items: cats.map((cat) {
          return DropdownMenuItem(
            value: cat,
            child: Row(
              children: [
                Container(
                  padding: AppTheme.paddingBadge,
                  decoration: BoxDecoration(
                    color: AppTheme.softBlue,
                    borderRadius: AppTheme.smallRadius,
                  ),
                  child: Text(
                    cat.code,
                    style: AppTheme.captionNavyBold,
                  ),
                ),
                Expanded(
                  child: Text(
                    VisaLocalization.getVisaName(cat.code, cat.name, l10n),
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyPrimaryRegular,
                  ),
                ),
                Text(
                  '\$${cat.baseFeeUsd}',
                  style: AppTheme.captionGreyRegular,
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
            _calculationRequested = false;
          });
        },
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context, dynamic l10n) {
    return Container(
      padding: AppTheme.paddingEstandar,
      decoration: BoxDecoration(
        color: AppTheme.inkInverse,
        borderRadius: AppTheme.inputRadius,
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: Column(
        children: [
          // Land crossing option
          SwitchListTile(
            title: Text(l10n.crossingByLand, style: AppTheme.bodyPrimaryRegular),
            subtitle: Text(l10n.crossingByLandSubtitle, style: AppTheme.captionGreyRegular),
            secondary: const Icon(Icons.directions_car, color: AppTheme.navyPrimary),
            activeColor: AppTheme.actionBlue,
            value: _crossingByLand,
            onChanged: (value) {
              setState(() {
                _crossingByLand = value;
                _calculationRequested = false;
              });
            },
          ),

          // SEVIS indicator (automatic based on category)
          if (_selectedCategory != null && _selectedCategory!.requiresSevis)
            ListTile(
              leading: const Icon(Icons.school, color: AppTheme.actionBlue),
              title: Text(l10n.sevisFeeIncluded, style: AppTheme.labelBold),
              subtitle: Text(
                _selectedCategory!.code == 'J1'
                    ? l10n.j1SevisFee
                    : l10n.fmSevisFee,
                style: AppTheme.captionGreyRegular,
              ),
              trailing: const Icon(Icons.check_circle, color: AppTheme.actionBlue),
            ),
        ],
      ),
    );
  }

  Widget _buildCalculationResult() {
    final l10n = context.l10n;
    final params = CostCalculationParams(
      countryCode: _selectedCountryCode!,
      visaCategoryCode: _selectedCategory!.code,
      baseFee: _selectedCategory!.baseFeeUsd,
      crossingByLand: _crossingByLand,
      requiresSevis: _selectedCategory!.requiresSevis,
    );

    final calculation = ref.watch(costCalculationProvider(params));

    return calculation.when(
      loading: () => const Center(
        child: Padding(
          padding: AppTheme.paddingExtraGrande,
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text(l10n.error(e.toString())),
      data: (calc) => CostBreakdownCard(calculation: calc),
    );
  }

  Widget _buildFeeSummaryCards(BuildContext context, dynamic l10n) {
    final fees = [
      (l10n.mrvFeeLabel, 'USD 185-315', Icons.receipt_long, AppTheme.navyPrimary),
      (l10n.integrityFeeLabel, 'USD 250', Icons.verified_user, AppTheme.actionBlue),
      (l10n.sevisFeeLabel, 'USD 220-350', Icons.school, AppTheme.actionBlue),
      (l10n.i94LandFeeLabel, 'USD 24', Icons.directions_car, AppTheme.navyPrimary),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.feeSchedule,
          style: AppTheme.h2NavyBold,
        ),
        SizedBox(height: AppTheme.espacioEntreGrupos),
        Wrap(
          spacing: AppTheme.espacioEntreGrupos,
          runSpacing: AppTheme.espacioEntreGrupos,
          children: fees.map((fee) {
            return Container(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              padding: AppTheme.paddingPequeno,
              decoration: BoxDecoration(
                color: AppTheme.inkInverse,
                borderRadius: AppTheme.inputRadius,
                border: Border.all(color: AppTheme.dividerGrey),
                boxShadow: [
                  BoxShadow(color: AppTheme.inkPrimary.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Icon(fee.$3, size: AppTheme.iconoEnTarjeta, color: fee.$4),
                  const SizedBox(width: AppTheme.espacioEntreCampos),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fee.$1,
                          style: AppTheme.captionGreyRegular.copyWith(fontSize: AppTheme.fuenteCaption),
                        ),
                        Text(
                          fee.$2,
                          style: AppTheme.h2NavyBold.copyWith(fontSize: AppTheme.fuenteBody),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
// ... (rest of file)

  void _calculate() {
    setState(() {
      _calculationRequested = true;
    });
  }

  void _showFeesInfo() {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppTheme.radiusModal),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: AppTheme.paddingGrande,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerGrey,
                      borderRadius: AppTheme.smallRadius,
                    ),
                  ),
                ),
                SizedBox(height: AppTheme.espacioEntreCards),
                Text(
                  l10n.understandingVisaFees,
                  style: AppTheme.h1NavyBold,
                ),
                SizedBox(height: AppTheme.espacioEntreSecciones),
                _buildInfoSection(
                  l10n.mrvFeeInfoTitle,
                  l10n.mrvFeeInfoDescription,
                ),
                _buildInfoSection(
                  l10n.integrityFeeInfoTitle,
                  l10n.integrityFeeInfoDescription,
                ),
                _buildInfoSection(
                  l10n.sevisFeeInfoTitle,
                  l10n.sevisFeeInfoDescription,
                ),
                _buildInfoSection(
                  l10n.i94FeeInfoTitle,
                  l10n.i94FeeInfoDescription,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.espacioEntreSecciones),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.labelBold,
          ),
          SizedBox(height: AppTheme.espacioEntreCampos),
          Text(
            content,
            style: AppTheme.bodyPrimaryRegular,
          ),
        ],
      ),
    );
  }
}
