// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_plans_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to fetch subscription plans from Supabase
/// Falls back to hardcoded defaults if DB is unavailable

@ProviderFor(subscriptionPlans)
const subscriptionPlansProvider = SubscriptionPlansProvider._();

/// Provider to fetch subscription plans from Supabase
/// Falls back to hardcoded defaults if DB is unavailable

final class SubscriptionPlansProvider extends $FunctionalProvider<
        AsyncValue<List<SubscriptionPlan>>,
        List<SubscriptionPlan>,
        FutureOr<List<SubscriptionPlan>>>
    with
        $FutureModifier<List<SubscriptionPlan>>,
        $FutureProvider<List<SubscriptionPlan>> {
  /// Provider to fetch subscription plans from Supabase
  /// Falls back to hardcoded defaults if DB is unavailable
  const SubscriptionPlansProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'subscriptionPlansProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$subscriptionPlansHash();

  @$internal
  @override
  $FutureProviderElement<List<SubscriptionPlan>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<SubscriptionPlan>> create(Ref ref) {
    return subscriptionPlans(ref);
  }
}

String _$subscriptionPlansHash() => r'7d4ab342b7cee1355ab44a10d20d2a5dc6763984';

/// Provider to get a specific plan by ID

@ProviderFor(subscriptionPlanById)
const subscriptionPlanByIdProvider = SubscriptionPlanByIdFamily._();

/// Provider to get a specific plan by ID

final class SubscriptionPlanByIdProvider extends $FunctionalProvider<
        AsyncValue<SubscriptionPlan?>,
        SubscriptionPlan?,
        FutureOr<SubscriptionPlan?>>
    with
        $FutureModifier<SubscriptionPlan?>,
        $FutureProvider<SubscriptionPlan?> {
  /// Provider to get a specific plan by ID
  const SubscriptionPlanByIdProvider._(
      {required SubscriptionPlanByIdFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'subscriptionPlanByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$subscriptionPlanByIdHash();

  @override
  String toString() {
    return r'subscriptionPlanByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SubscriptionPlan?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionPlan?> create(Ref ref) {
    final argument = this.argument as String;
    return subscriptionPlanById(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SubscriptionPlanByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subscriptionPlanByIdHash() =>
    r'a59267838371c34f325cd0e48088895903e5b39c';

/// Provider to get a specific plan by ID

final class SubscriptionPlanByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SubscriptionPlan?>, String> {
  const SubscriptionPlanByIdFamily._()
      : super(
          retry: null,
          name: r'subscriptionPlanByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Provider to get a specific plan by ID

  SubscriptionPlanByIdProvider call(
    String planId,
  ) =>
      SubscriptionPlanByIdProvider._(argument: planId, from: this);

  @override
  String toString() => r'subscriptionPlanByIdProvider';
}
