import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/features/payments/presentation/providers/payments_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Production-ready order summary with Stripe payment integration.
/// Migration: 2026-01-20 - Implemented payment flow with Stripe.
class OrderSummaryScreen extends ConsumerStatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  ConsumerState<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends ConsumerState<OrderSummaryScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment(double total, String planTitle) async {
    setState(() => _isProcessing = true);

    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      // PRODUCTION: Call Edge Function to create Stripe PaymentIntent
      final response = await supabase.functions.invoke(
        'stripe-payment-intent',
        body: {
          'amount': (total * 100).toInt(), // Stripe uses cents
          'currency': 'usd',
          'metadata': {
            'user_id': userId,
            'plan': planTitle,
          },
        },
      );

      if (response.status != 200) {
        throw Exception('Error creando pago: ${response.data}');
      }

      final paymentData = response.data as Map<String, dynamic>;
      final clientSecret = paymentData['clientSecret'] as String;

      // Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'USA Visa Center',
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful - update application status
      await supabase.from('applications').update({
        'status': 'paid',
        'paid_at': DateTime.now().toIso8601String(),
        'payment_amount': total,
      }).eq('user_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Pago completado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/dashboard');
      }
    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pago cancelado: ${e.error.localizedMessage}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
    final plansAsync = ref.watch(servicePlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen del Pedido', style: GoogleFonts.publicSans(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF112E51),
        foregroundColor: Colors.white,
      ),
      body: plansAsync.when(
        data: (plans) {
          // Get selected plan (popular or first)
          final selectedPlan = plans.isNotEmpty 
              ? plans.firstWhere((p) => p.isPopular, orElse: () => plans.first)
              : null;
          
          if (selectedPlan == null) {
            return const Center(child: Text('No hay planes disponibles'));
          }

          final items = [
            {'name': selectedPlan.title, 'price': selectedPlan.price},
            {'name': 'Procesamiento Prioritario', 'price': 10.00},
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
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
                      Text('Total', style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF112E51),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing 
                        ? null 
                        : () => _processPayment(total, selectedPlan.title),
                    icon: _isProcessing 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.payment),
                    label: Text(_isProcessing ? 'Procesando...' : 'Pagar \$${total.toStringAsFixed(2)}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF112E51),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Secure payment badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Pago seguro con Stripe',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
