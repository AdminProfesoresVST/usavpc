// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(servicePlans)
const servicePlansProvider = ServicePlansProvider._();

final class ServicePlansProvider extends $FunctionalProvider<
        AsyncValue<List<ServicePlan>>,
        List<ServicePlan>,
        FutureOr<List<ServicePlan>>>
    with
        $FutureModifier<List<ServicePlan>>,
        $FutureProvider<List<ServicePlan>> {
  const ServicePlansProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'servicePlansProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$servicePlansHash();

  @$internal
  @override
  $FutureProviderElement<List<ServicePlan>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ServicePlan>> create(Ref ref) {
    return servicePlans(ref);
  }
}

String _$servicePlansHash() => r'6c04a8c1b0dbe259f94bb7b6c19a69bc69e43d32';
