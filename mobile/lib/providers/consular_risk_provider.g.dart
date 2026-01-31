// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consular_risk_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Consular Risk Provider
/// Implements 9 FAM weighted scoring algorithm from consular-singularity-engine skill.
///
/// Weights based on 9 FAM 401.1 priorities:
/// - Economic Ties (Ve): 30%
/// - Social Anchors (Vs): 25%
/// - Documentary Integrity: 20%
/// - Travel History (Vh): 15%
/// - Consistency/Honesty (Vc): 10%

@ProviderFor(ConsularRisk)
final consularRiskProvider = ConsularRiskProvider._();

/// Consular Risk Provider
/// Implements 9 FAM weighted scoring algorithm from consular-singularity-engine skill.
///
/// Weights based on 9 FAM 401.1 priorities:
/// - Economic Ties (Ve): 30%
/// - Social Anchors (Vs): 25%
/// - Documentary Integrity: 20%
/// - Travel History (Vh): 15%
/// - Consistency/Honesty (Vc): 10%
final class ConsularRiskProvider
    extends $NotifierProvider<ConsularRisk, ConsularRiskState> {
  /// Consular Risk Provider
  /// Implements 9 FAM weighted scoring algorithm from consular-singularity-engine skill.
  ///
  /// Weights based on 9 FAM 401.1 priorities:
  /// - Economic Ties (Ve): 30%
  /// - Social Anchors (Vs): 25%
  /// - Documentary Integrity: 20%
  /// - Travel History (Vh): 15%
  /// - Consistency/Honesty (Vc): 10%
  ConsularRiskProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'consularRiskProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$consularRiskHash();

  @$internal
  @override
  ConsularRisk create() => ConsularRisk();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsularRiskState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsularRiskState>(value),
    );
  }
}

String _$consularRiskHash() => r'e6627afa292f873d37e9ae94908683515a19daf6';

/// Consular Risk Provider
/// Implements 9 FAM weighted scoring algorithm from consular-singularity-engine skill.
///
/// Weights based on 9 FAM 401.1 priorities:
/// - Economic Ties (Ve): 30%
/// - Social Anchors (Vs): 25%
/// - Documentary Integrity: 20%
/// - Travel History (Vh): 15%
/// - Consistency/Honesty (Vc): 10%

abstract class _$ConsularRisk extends $Notifier<ConsularRiskState> {
  ConsularRiskState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ConsularRiskState, ConsularRiskState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ConsularRiskState, ConsularRiskState>,
        ConsularRiskState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
