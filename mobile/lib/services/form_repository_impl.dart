import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/models/form_schema.dart';
import 'package:mobile/services/form_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Production-ready form repository that fetches dynamic form schemas from Supabase.
/// Migration: 2026-01-17 - Replaced hardcoded mock data with real DB calls.
class FormRepositoryImpl implements FormRepository {
  final SupabaseClient _supabase;

  FormRepositoryImpl(this._supabase);

  @override
  Future<List<FormStepSchema>> getFormSteps() async {
    // PRODUCTION: Real database query for form schemas
    final response = await _supabase
        .from('form_schemas')
        .select('title, schema')
        .eq('is_active', true)
        .order('step_order', ascending: true);

    return (response as List<dynamic>).map((json) {
      final data = json as Map<String, dynamic>;
      return FormStepSchema(
        title: data['title'] as String,
        schema: data['schema'] as Map<String, dynamic>,
      );
    }).toList();
  }
}

final formRepositoryProvider = Provider<FormRepository>((ref) {
  return FormRepositoryImpl(ref.watch(supabaseClientProvider));
});
