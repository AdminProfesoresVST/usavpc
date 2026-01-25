import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../visa/data/models/visa_category.dart';
import '../../../visa/presentation/providers/visa_providers.dart';
import '../providers/cost_calculator_providers.dart';
import '../widgets/cost_breakdown_card.dart';

/// Pantalla de calculadora de costos de visa
class CostCalculatorScreen extends ConsumerStatefulWidget {
  const CostCalculatorScreen({super.key});

  @override
  ConsumerState<CostCalculatorScreen> createState() => _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends ConsumerState<CostCalculatorScreen> {
  String? _selectedCountryCode;
  VisaCategory? _selectedCategory;
  bool _crossingByLand = false;
  bool _calculationRequested = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = ref.watch(visaCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Calculator'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showFeesInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.secondaryContainer,
                    colorScheme.secondaryContainer.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calculate_outlined,
                      color: colorScheme.secondary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Know Your Total',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Calculate all fees for your visa application',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Currency selector
            Text(
              'Your Nationality',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildCountryDropdown(context),

            const SizedBox(height: 20),

            // Visa Category
            Text(
              'Visa Category',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildCategoryDropdown(context, categories),

            const SizedBox(height: 20),

            // Options
            Text(
              'Additional Options',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildOptionsCard(context),

            const SizedBox(height: 24),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _canCalculate ? _calculate : null,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Total Cost'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Result
            if (_calculationRequested && _selectedCategory != null)
              _buildCalculationResult(),

            const SizedBox(height: 32),

            // Fee summary cards
            _buildFeeSummaryCards(context),
          ],
        ),
      ),
    );
  }

  bool get _canCalculate =>
      _selectedCountryCode != null && _selectedCategory != null;

  Widget _buildCountryDropdown(BuildContext context) {
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
      decoration: InputDecoration(
        hintText: 'Select your country',
        prefixIcon: const Icon(Icons.public),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      items: countries.map((c) {
        return DropdownMenuItem(
          value: c.$1,
          child: Text(c.$2),
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
  ) {
    return categories.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
      data: (cats) => DropdownButtonFormField<VisaCategory>(
        value: _selectedCategory,
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
            value: cat,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cat.type.isImmigrant
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    cat.code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cat.type.isImmigrant ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(cat.name)),
                Text(
                  '\$${cat.baseFeeUsd}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
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

  Widget _buildOptionsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Land crossing option
          SwitchListTile(
            title: const Text('Crossing by Land'),
            subtitle: const Text('Adds I-94 fee (\$24)'),
            secondary: const Icon(Icons.directions_car),
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
              leading: const Icon(Icons.school, color: Colors.teal),
              title: const Text('SEVIS Fee Included'),
              subtitle: Text(
                _selectedCategory!.code == 'J1'
                    ? 'J-1 SEVIS: \$220'
                    : 'F/M SEVIS: \$350',
              ),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
        ],
      ),
    );
  }

  Widget _buildCalculationResult() {
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
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text('Error: $e'),
      data: (calc) => CostBreakdownCard(calculation: calc),
    );
  }

  Widget _buildFeeSummaryCards(BuildContext context) {
    final theme = Theme.of(context);
    final fees = [
      ('MRV Fee', '\$185-\$315', Icons.receipt_long, Colors.blue),
      ('Integrity', '\$250', Icons.verified_user, Colors.purple),
      ('SEVIS', '\$220-\$350', Icons.school, Colors.teal),
      ('I-94 Land', '\$24', Icons.directions_car, Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2026 Fee Schedule',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fees.map((fee) {
            return Container(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fee.$4.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: fee.$4.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(fee.$3, size: 20, color: fee.$4),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fee.$1,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: fee.$4,
                          ),
                        ),
                        Text(
                          fee.$2,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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

  void _calculate() {
    setState(() {
      _calculationRequested = true;
    });
  }

  void _showFeesInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Understanding Visa Fees (2026)',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  'MRV Fee (Non-refundable)',
                  'The Machine Readable Visa fee is paid when scheduling your interview. '
                  'It varies by visa category:\n'
                  '• \$185: B1/B2, F, M, J, TN\n'
                  '• \$205: H, L, O, P, Q, R\n'
                  '• \$265: K (Fiancé)\n'
                  '• \$315: E (Treaty)',
                ),
                _buildInfoSection(
                  'Visa Integrity Fee (NEW)',
                  'A new \$250 fee implemented in 2026 for most non-immigrant visas. '
                  'This fee MAY be partially refundable if you depart the US on time '
                  'with proof of departure (boarding pass submission).',
                ),
                _buildInfoSection(
                  'SEVIS I-901 Fee',
                  'Required for students and exchange visitors:\n'
                  '• \$350: F-1 and M-1 students\n'
                  '• \$220: J-1 exchange visitors\n'
                  'Pay at fmjfee.com BEFORE your interview.',
                ),
                _buildInfoSection(
                  'I-94 Land Border Fee',
                  'Increased from \$6 to \$24 in 2026. Only applies if entering '
                  'the US by land (Mexico/Canada border crossings).',
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
