import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mobile/models/visa_category.dart';
import 'package:mobile/models/country_restriction.dart';

/// Repository para restricciones de países
abstract class ICountryRestrictionRepository {
  Future<CountryRestriction?> getByCountryCode(String countryCode);
  Future<List<CountryRestriction>> getAllRestricted();
  Future<List<CountryRestriction>> getByLevel(RestrictionLevel level);
  Future<RestrictionCheckResult> checkRestrictions({
    required String countryCode,
    required String visaCategoryCode,
    required FormEngine formEngine,
  });
}

/// Implementación de Supabase para CountryRestrictionRepository
class CountryRestrictionRepository implements ICountryRestrictionRepository {
  final SupabaseClient _client;
  static const String _tableName = 'country_restrictions';

  CountryRestrictionRepository(this._client);

  @override
  Future<CountryRestriction?> getByCountryCode(String countryCode) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('country_code', countryCode.toUpperCase())
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return CountryRestriction.fromJson(response);
  }

  @override
  Future<List<CountryRestriction>> getAllRestricted() async {
    final response = await _client
        .from(_tableName)
        .select()
        .neq('restriction_level', 'none')
        .eq('is_active', true)
        .order('country_name');

    return (response as List)
        .map((json) => CountryRestriction.fromJson(json))
        .toList();
  }

  @override
  Future<List<CountryRestriction>> getByLevel(RestrictionLevel level) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('restriction_level', level.value)
        .eq('is_active', true)
        .order('country_name');

    return (response as List)
        .map((json) => CountryRestriction.fromJson(json))
        .toList();
  }

  @override
  Future<RestrictionCheckResult> checkRestrictions({
    required String countryCode,
    required String visaCategoryCode,
    required FormEngine formEngine,
  }) async {
    final restriction = await getByCountryCode(countryCode);

    // Si no hay restricción, permitir
    if (restriction == null) {
      return RestrictionCheckResult.allowed();
    }

    switch (restriction.restrictionLevel) {
      case RestrictionLevel.totalBan:
        // Prohibición total - bloquear todo
        return RestrictionCheckResult.blocked(
          level: RestrictionLevel.totalBan,
          countryName: restriction.countryName,
          message:
              'Nationals of ${restriction.countryName} are currently prohibited from entering the United States.',
        );

      case RestrictionLevel.immigrantPause:
        // Solo bloquea DS-260 (inmigrante)
        if (formEngine == FormEngine.ds260) {
          return RestrictionCheckResult.blocked(
            level: RestrictionLevel.immigrantPause,
            countryName: restriction.countryName,
            message:
                'Immigrant visa processing for ${restriction.countryName} is currently paused.',
          );
        }
        return RestrictionCheckResult.allowed();

      case RestrictionLevel.partialRestriction:
        // Verificar si la categoría específica está restringida
        if (restriction.isCategoryRestricted(visaCategoryCode)) {
          return RestrictionCheckResult.blocked(
            level: RestrictionLevel.partialRestriction,
            countryName: restriction.countryName,
            message:
                '$visaCategoryCode visas for ${restriction.countryName} are currently suspended.',
            blockedCategories: restriction.restrictedCategories,
          );
        }
        return RestrictionCheckResult.allowed();

      case RestrictionLevel.none:
        return RestrictionCheckResult.allowed();
    }
  }
}
