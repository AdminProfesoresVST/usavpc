import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/models/visa_fee.dart';
import 'package:mobile/services/visa_fee_repository.dart';

/// Provider del repository de tarifas
final visaFeeRepositoryProvider = Provider<IVisaFeeRepository>((ref) {
  return VisaFeeRepository(ref.watch(supabaseClientProvider));
});

/// Provider de todas las tarifas
final allVisaFeesProvider = FutureProvider<List<VisaFee>>((ref) async {
  final repository = ref.watch(visaFeeRepositoryProvider);
  return repository.getAll();
});

/// Provider de Integrity Fee
final integrityFeeProvider = FutureProvider<VisaFee?>((ref) async {
  final repository = ref.watch(visaFeeRepositoryProvider);
  return repository.getIntegrityFee();
});

/// Provider de SEVIS Fee por categoría
final sevisFeeProvider = FutureProvider.family<VisaFee?, String>((ref, categoryCode) async {
  final repository = ref.watch(visaFeeRepositoryProvider);
  return repository.getSevisFee(categoryCode);
});

/// Provider de I-94 Land Fee
final i94LandFeeProvider = FutureProvider<VisaFee?>((ref) async {
  final repository = ref.watch(visaFeeRepositoryProvider);
  return repository.getI94LandFee();
});

/// Parámetros para cálculo de costo
class CostCalculationParams {
  final String countryCode;
  final String visaCategoryCode;
  final int baseFee;
  final bool crossingByLand;
  final bool requiresSevis;

  const CostCalculationParams({
    required this.countryCode,
    required this.visaCategoryCode,
    required this.baseFee,
    this.crossingByLand = false,
    this.requiresSevis = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CostCalculationParams &&
        other.countryCode == countryCode &&
        other.visaCategoryCode == visaCategoryCode &&
        other.baseFee == baseFee &&
        other.crossingByLand == crossingByLand &&
        other.requiresSevis == requiresSevis;
  }

  @override
  int get hashCode => Object.hash(
        countryCode,
        visaCategoryCode,
        baseFee,
        crossingByLand,
        requiresSevis,
      );
}

/// Provider de cálculo de costo total
final costCalculationProvider = FutureProvider.family<CostCalculation, CostCalculationParams>((ref, params) async {
  final repository = ref.watch(visaFeeRepositoryProvider);
  return repository.calculateTotal(
    countryCode: params.countryCode,
    visaCategoryCode: params.visaCategoryCode,
    baseFee: params.baseFee,
    crossingByLand: params.crossingByLand,
    requiresSevis: params.requiresSevis,
  );
});

/// Estado de cruce por tierra
class CrossingByLandNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final crossingByLandProvider = NotifierProvider<CrossingByLandNotifier, bool>(
  CrossingByLandNotifier.new,
);

/// Estado de requiere SEVIS
class RequiresSevisNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

final requiresSevisProvider = NotifierProvider<RequiresSevisNotifier, bool>(
  RequiresSevisNotifier.new,
);

/// Estado de cálculo actual
class CurrentCostCalculationNotifier extends Notifier<CostCalculation?> {
  @override
  CostCalculation? build() => null;
  
  void set(CostCalculation? calculation) => state = calculation;
  void clear() => state = null;
}

final currentCostCalculationProvider = NotifierProvider<CurrentCostCalculationNotifier, CostCalculation?>(
  CurrentCostCalculationNotifier.new,
);
