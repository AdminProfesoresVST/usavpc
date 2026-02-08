import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/services/payment_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'payment_provider.g.dart';

/// Provider for the PaymentService singleton
@riverpod
// ignore: strict_top_level_inference
PaymentService paymentService(ref) {
  final service = PaymentService();
  // Initialize when first accessed
  service.initialize();
  return service;
}

/// Provider to check if user has active subscription
@riverpod
// ignore: strict_top_level_inference
Future<bool> hasActiveSubscription(ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) return false;
  
  final response = await supabase
      .from('user_subscriptions')
      .select()
      .eq('user_id', userId)
      .eq('status', 'active')
      .gte('expires_at', DateTime.now().toIso8601String())
      .limit(1);
  
  return (response as List).isNotEmpty;
}

/// Provider to get available products from store
@riverpod
// ignore: strict_top_level_inference
Future<List<ProductDetails>> availableProducts(ref) async {
  final service = ref.watch(paymentServiceProvider);
  
  // Wait for products to load
  if (service.products.isEmpty) {
    await service.loadProducts();
  }
  
  return service.products;
}

/// Provider to get user's subscription history
@riverpod
// ignore: strict_top_level_inference
Future<List<Map<String, dynamic>>> userSubscriptions(ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) return [];
  
  final response = await supabase
      .from('user_subscriptions')
      .select('*, subscription_plans(*)')
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  
  return List<Map<String, dynamic>>.from(response);
}
