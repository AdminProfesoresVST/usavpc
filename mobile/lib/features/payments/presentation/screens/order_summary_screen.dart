import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/payments/presentation/providers/payments_provider.dart';

class OrderSummaryScreen extends ConsumerWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In real app: cartProvider. Here: simulating by fetching 'popular' plan
    final plansAsync = ref.watch(servicePlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Summary')),
      body: plansAsync.when(
        data: (plans) {
             // Simulate cart: take the first popular item + a fee
             final selectedPlan = plans.firstWhere((p) => p.isPopular);
             final items = [
               {'name': selectedPlan.title, 'price': selectedPlan.price},
               {'name': 'Priority Processing', 'price': 10.00},
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
                            trailing: Text('\$${(item['price'] as double).toStringAsFixed(2)}'),
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
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Trigger Stripe Payment Sheet
                        },
                        icon: const Icon(Icons.apple), // Just an icon for now, would be custom asset
                        label: const Text('Pay with Apple Pay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
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
