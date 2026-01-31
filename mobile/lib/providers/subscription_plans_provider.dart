import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'subscription_plans_provider.g.dart';

/// Subscription Plan Model
class SubscriptionPlan {
  final String id;
  final String title;
  final double price;
  final String priceFormatted;
  final String billingPeriod;
  final String? description;
  final List<String> features;
  final String? savingsText;
  final bool isPopular;
  final bool isActive;
  final int displayOrder;

  const SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.priceFormatted,
    required this.billingPeriod,
    this.description,
    required this.features,
    this.savingsText,
    this.isPopular = false,
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      priceFormatted: json['price_formatted'] as String,
      billingPeriod: json['billing_period'] as String,
      description: json['description'] as String?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      savingsText: json['savings_text'] as String?,
      isPopular: json['is_popular'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'price_formatted': priceFormatted,
    'billing_period': billingPeriod,
    'description': description,
    'features': features,
    'savings_text': savingsText,
    'is_popular': isPopular,
    'is_active': isActive,
    'display_order': displayOrder,
  };
}

/// Provider to fetch subscription plans from Supabase
/// Falls back to hardcoded defaults if DB is unavailable
@riverpod
Future<List<SubscriptionPlan>> subscriptionPlans(Ref ref) async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('subscription_plans')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);
    
    if (response.isEmpty) {
      return _defaultPlans;
    }
    
    return (response as List)
        .map((json) => SubscriptionPlan.fromJson(json))
        .toList();
  } catch (e) {
    // Fallback to defaults if table doesn't exist yet
    return _defaultPlans;
  }
}

/// Provider to get a specific plan by ID
@riverpod
Future<SubscriptionPlan?> subscriptionPlanById(Ref ref, String planId) async {
  final plans = await ref.watch(subscriptionPlansProvider.future);
  try {
    return plans.firstWhere((p) => p.id == planId);
  } catch (_) {
    return null;
  }
}

/// Default plans as fallback
const _defaultPlans = [
  SubscriptionPlan(
    id: 'monthly',
    title: 'Plan Mensual',
    price: 9.99,
    priceFormatted: '\$9.99/mes',
    billingPeriod: 'monthly',
    description: 'Acceso básico al simulador',
    features: ['Simulador IA', 'Tips básicos', 'Acceso estándar'],
    isPopular: false,
    displayOrder: 1,
  ),
  SubscriptionPlan(
    id: 'yearly',
    title: 'Plan Anual',
    price: 59.99,
    priceFormatted: '\$59.99/año',
    billingPeriod: 'yearly',
    description: 'Acceso completo con ahorro',
    features: ['Simulador IA ilimitado', 'Soporte prioritario', 'Sin anuncios'],
    savingsText: 'Ahorra 50%',
    isPopular: true,
    displayOrder: 2,
  ),
];
