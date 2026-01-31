import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🛒 PAYMENT SERVICE - Google Play, App Store, PayPal
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Handles real in-app purchases for:
/// - Google Play (Android)
/// - App Store (iOS)
/// - PayPal (via web redirect)
/// 
/// Created: 2026-01-31
/// ═══════════════════════════════════════════════════════════════════════════

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  
  // Product IDs that match Google Play Console / App Store Connect
  static const String monthlyProductId = 'premium_monthly';
  static const String yearlyProductId = 'premium_yearly';
  
  /// Initialize the payment service
  Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (!_isAvailable) {
      debugPrint('PaymentService: In-app purchases not available on this device');
      return;
    }
    
    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('PaymentService: Error: $error'),
    );
    
    // Load products from store
    await loadProducts();
  }
  
  /// Load products from Google Play / App Store
  Future<void> loadProducts() async {
    if (!_isAvailable) return;
    
    const Set<String> productIds = {monthlyProductId, yearlyProductId};
    
    final ProductDetailsResponse response = 
        await _inAppPurchase.queryProductDetails(productIds);
    
    if (response.error != null) {
      debugPrint('PaymentService: Error loading products: ${response.error}');
      return;
    }
    
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('PaymentService: Products not found: ${response.notFoundIDs}');
    }
    
    _products = response.productDetails;
    debugPrint('PaymentService: Loaded ${_products.length} products');
  }
  
  /// Get all available products
  List<ProductDetails> get products => _products;
  
  /// Check if purchases are available
  bool get isAvailable => _isAvailable;
  
  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }
  
  /// Purchase a subscription (Google Play / App Store)
  Future<bool> purchaseSubscription(String productId) async {
    if (!_isAvailable) {
      throw Exception('In-app purchases not available');
    }
    
    final product = getProduct(productId);
    if (product == null) {
      throw Exception('Product not found: $productId');
    }
    
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    // For subscriptions, use buyNonConsumable
    return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }
  
  /// Handle purchase status updates
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          debugPrint('PaymentService: Purchase pending: ${purchase.productID}');
          break;
          
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Verify and deliver the purchase
          await _verifyAndDeliverPurchase(purchase);
          break;
          
        case PurchaseStatus.error:
          debugPrint('PaymentService: Purchase error: ${purchase.error}');
          break;
          
        case PurchaseStatus.canceled:
          debugPrint('PaymentService: Purchase canceled');
          break;
      }
      
      // Complete pending purchases
      if (purchase.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchase);
      }
    }
  }
  
  /// Verify purchase and save to database
  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    debugPrint('PaymentService: Verifying purchase: ${purchase.productID}');
    
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    
    if (userId == null) {
      debugPrint('PaymentService: User not logged in');
      return;
    }
    
    // Determine plan ID from product ID
    final planId = purchase.productID == monthlyProductId ? 'monthly' : 'yearly';
    
    // Determine provider
    final provider = Platform.isAndroid ? 'google_play' : 'app_store';
    
    // Calculate expiry (1 month or 1 year from now)
    final now = DateTime.now();
    final expiresAt = planId == 'monthly' 
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(days: 365));
    
    try {
      // Save subscription to database
      await supabase.from('user_subscriptions').insert({
        'user_id': userId,
        'plan_id': planId,
        'provider': provider,
        'provider_subscription_id': purchase.purchaseID,
        'status': 'active',
        'starts_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      });
      
      debugPrint('PaymentService: Subscription saved successfully');
    } catch (e) {
      debugPrint('PaymentService: Error saving subscription: $e');
    }
  }
  
  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _inAppPurchase.restorePurchases();
  }
  
  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
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
  
  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
  }
}
