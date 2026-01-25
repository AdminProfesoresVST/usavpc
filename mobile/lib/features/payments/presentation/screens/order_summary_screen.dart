import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/extensions/build_context_extensions.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/app_header.dart';
import 'package:mobile/features/payments/presentation/providers/payments_provider.dart';
import 'package:mobile/core/utils/plan_localization.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Production-ready order summary with Stripe payment integration and full i18n.
/// Updated: 2026-01-21 - Applied i18n and AppHeader per audit requirements
class OrderSummaryScreen extends ConsumerStatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  ConsumerState<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends ConsumerState<OrderSummaryScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment(double total, String planTitle) async {
    setState(() => _isProcessing = true);
    final l10n = context.l10n;

    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception(l10n.userNotAuthenticated);

      final response = await supabase.functions.invoke(
        'stripe-payment-intent',
        body: {
          'amount': (total * 100).toInt(),
          'currency': 'usd',
          'metadata': {
            'user_id': userId,
            'plan': planTitle,
          },
        },
      );

      if (response.status != 200) {
        throw Exception('Error: ${response.data}');
      }

      final paymentData = response.data as Map<String, dynamic>;
      final clientSecret = paymentData['clientSecret'] as String;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'USA Visa Center',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await supabase.from('applications').update({
        'status': 'paid',
        'paid_at': DateTime.now().toIso8601String(),
        'payment_amount': total,
      }).eq('user_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${l10n.paymentCompleted}'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        context.go('/dashboard');
      }
    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paymentCancelled(e.error.localizedMessage ?? ''))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plansAsync = ref.watch(servicePlansProvider);

    return Scaffold(
      appBar: AppHeader(title: l10n.orderSummaryTitle),
      body: plansAsync.when(
        data: (plans) {
          final selectedPlan = plans.isNotEmpty 
              ? plans.firstWhere((p) => p.isPopular, orElse: () => plans.first)
              : null;
          
          if (selectedPlan == null) {
            return Center(child: Text(l10n.noPlansAvailable));
          }

          final items = [
            {'name': PlanLocalization.getTitle(selectedPlan.id, selectedPlan.title, l10n), 'price': selectedPlan.price},
            {'name': l10n.priorityProcessing, 'price': 10.00},
          ];

          double total = items.fold(0, (sum, item) => sum + (item['price'] as double));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item['name'] as String),
                        trailing: Text(
                          '\$${(item['price'] as double).toStringAsFixed(2)}',
                          style: AppTheme.h2NavyBold,
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.total, style: AppTheme.h2NavyBold),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: AppTheme.h1NavyBold,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.alturaBotonGrande,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing 
                        ? null 
                        : () => _processPayment(total, PlanLocalization.getTitle(selectedPlan.id, selectedPlan.title, l10n)),
                    icon: _isProcessing 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.inkInverse),
                          )
                        : const Icon(Icons.payment),
                    label: Text(_isProcessing ? l10n.processing : l10n.payButton('\$${total.toStringAsFixed(2)}')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.navyPrimary,
                      foregroundColor: AppTheme.inkInverse,
                      disabledBackgroundColor: AppTheme.dividerGrey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 14, color: AppTheme.inkSecondary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.securePayment,
                      style: AppTheme.captionGreyRegular,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(l10n.error(err.toString()))),
      ),
    );
  }
}
