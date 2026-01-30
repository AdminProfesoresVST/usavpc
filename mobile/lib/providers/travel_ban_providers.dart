import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/models/country_restriction.dart';
import 'package:mobile/services/country_restriction_repository.dart';
import 'package:mobile/models/visa_category.dart';

/// Provider del repository de restricciones de países
final countryRestrictionRepositoryProvider = Provider<ICountryRestrictionRepository>((ref) {
  return CountryRestrictionRepository(ref.watch(supabaseClientProvider));
});

/// Provider de restricción por código de país
final countryRestrictionProvider = FutureProvider.family<CountryRestriction?, String>((ref, countryCode) async {
  final repository = ref.watch(countryRestrictionRepositoryProvider);
  return repository.getByCountryCode(countryCode);
});

/// Provider de todos los países restringidos
final allRestrictedCountriesProvider = FutureProvider<List<CountryRestriction>>((ref) async {
  final repository = ref.watch(countryRestrictionRepositoryProvider);
  return repository.getAllRestricted();
});

/// Provider de países con prohibición total
final totalBanCountriesProvider = FutureProvider<List<CountryRestriction>>((ref) async {
  final repository = ref.watch(countryRestrictionRepositoryProvider);
  return repository.getByLevel(RestrictionLevel.totalBan);
});

/// Provider de países con restricción parcial
final partialRestrictionCountriesProvider = FutureProvider<List<CountryRestriction>>((ref) async {
  final repository = ref.watch(countryRestrictionRepositoryProvider);
  return repository.getByLevel(RestrictionLevel.partialRestriction);
});

/// Provider de países con pausa de inmigrante
final immigrantPauseCountriesProvider = FutureProvider<List<CountryRestriction>>((ref) async {
  final repository = ref.watch(countryRestrictionRepositoryProvider);
  return repository.getByLevel(RestrictionLevel.immigrantPause);
});

/// Parámetros para verificar restricciones
class RestrictionCheckParams {
  final String countryCode;
  final String visaCategoryCode;
  final FormEngine formEngine;

  const RestrictionCheckParams({
    required this.countryCode,
    required this.visaCategoryCode,
    required this.formEngine,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestrictionCheckParams &&
        other.countryCode == countryCode &&
        other.visaCategoryCode == visaCategoryCode &&
        other.formEngine == formEngine;
  }

  @override
  int get hashCode => Object.hash(countryCode, visaCategoryCode, formEngine);
}

/// Provider de verificación de restricciones
final restrictionCheckProvider = FutureProvider.family<RestrictionCheckResult, RestrictionCheckParams>((ref, params) async {
  final repository = ref.watch(countryRestrictionRepositoryProvider);
  return repository.checkRestrictions(
    countryCode: params.countryCode,
    visaCategoryCode: params.visaCategoryCode,
    formEngine: params.formEngine,
  );
});

/// Estado del país seleccionado
class SelectedCountryCodeNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void set(String? code) => state = code;
  void clear() => state = null;
}

final selectedCountryCodeProvider = NotifierProvider<SelectedCountryCodeNotifier, String?>(
  SelectedCountryCodeNotifier.new,
);
