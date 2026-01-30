import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/visa_category.dart';

/// Repository para categorías de visa
abstract class IVisaCategoryRepository {
  Future<List<VisaCategory>> getAll();
  Future<VisaCategory?> getByCode(String code);
  Future<List<VisaCategory>> getByType(VisaType type);
  Future<List<VisaCategory>> getByFormEngine(FormEngine engine);
}

/// Implementación de Supabase para VisaCategoryRepository
class VisaCategoryRepository implements IVisaCategoryRepository {
  final SupabaseClient _client;
  static const String _tableName = 'visa_categories';

  VisaCategoryRepository(this._client);

  @override
  Future<List<VisaCategory>> getAll() async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('is_active', true)
        .order('code');

    return (response as List)
        .map((json) => VisaCategory.fromJson(json))
        .toList();
  }

  @override
  Future<VisaCategory?> getByCode(String code) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('code', code)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return VisaCategory.fromJson(response);
  }

  @override
  Future<List<VisaCategory>> getByType(VisaType type) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('type', type.value)
        .eq('is_active', true)
        .order('code');

    return (response as List)
        .map((json) => VisaCategory.fromJson(json))
        .toList();
  }

  @override
  Future<List<VisaCategory>> getByFormEngine(FormEngine engine) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('form_engine', engine.value)
        .eq('is_active', true)
        .order('code');

    return (response as List)
        .map((json) => VisaCategory.fromJson(json))
        .toList();
  }
}
