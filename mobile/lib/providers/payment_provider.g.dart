// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the PaymentService singleton

@ProviderFor(paymentService)
const paymentServiceProvider = PaymentServiceProvider._();

/// Provider for the PaymentService singleton

final class PaymentServiceProvider
    extends $FunctionalProvider<PaymentService, PaymentService, PaymentService>
    with $Provider<PaymentService> {
  /// Provider for the PaymentService singleton
  const PaymentServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'paymentServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$paymentServiceHash();

  @$internal
  @override
  $ProviderElement<PaymentService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PaymentService create(Ref ref) {
    return paymentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentService>(value),
    );
  }
}

String _$paymentServiceHash() => r'7dd031e94e4a319931aa5ec11271d5a7eefe92f6';

/// Provider to check if user has active subscription

@ProviderFor(hasActiveSubscription)
const hasActiveSubscriptionProvider = HasActiveSubscriptionProvider._();

/// Provider to check if user has active subscription

final class HasActiveSubscriptionProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider to check if user has active subscription
  const HasActiveSubscriptionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'hasActiveSubscriptionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$hasActiveSubscriptionHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasActiveSubscription(ref);
  }
}

String _$hasActiveSubscriptionHash() =>
    r'30cf8b8e5b3843562386c245cfd5d6b22c021232';

/// Provider to get available products from store

@ProviderFor(availableProducts)
const availableProductsProvider = AvailableProductsProvider._();

/// Provider to get available products from store

final class AvailableProductsProvider extends $FunctionalProvider<
        AsyncValue<List<ProductDetails>>,
        List<ProductDetails>,
        FutureOr<List<ProductDetails>>>
    with
        $FutureModifier<List<ProductDetails>>,
        $FutureProvider<List<ProductDetails>> {
  /// Provider to get available products from store
  const AvailableProductsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'availableProductsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$availableProductsHash();

  @$internal
  @override
  $FutureProviderElement<List<ProductDetails>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductDetails>> create(Ref ref) {
    return availableProducts(ref);
  }
}

String _$availableProductsHash() => r'3c2be4c27cdce47e5720d089e32f60a7f84475c5';

/// Provider to get user's subscription history

@ProviderFor(userSubscriptions)
const userSubscriptionsProvider = UserSubscriptionsProvider._();

/// Provider to get user's subscription history

final class UserSubscriptionsProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        FutureOr<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Provider to get user's subscription history
  const UserSubscriptionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userSubscriptionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userSubscriptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return userSubscriptions(ref);
  }
}

String _$userSubscriptionsHash() => r'990fcc67b77efc7228f46740ffe326828667d6a6';
