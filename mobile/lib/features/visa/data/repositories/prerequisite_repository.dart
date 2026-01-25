import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/prerequisite_form.dart';

/// Repository para formularios prerrequisito
abstract class IPrerequisiteRepository {
  Future<List<PrerequisiteForm>> getByCategory(String visaCategoryCode);
  Future<PrerequisiteForm?> getById(String id);
  Future<List<PrerequisiteValidation>> getValidationsForApplication(String applicationId);
  Future<PrerequisiteValidation> saveValidation(PrerequisiteValidation validation);
  Future<void> updateValidationStatus(
    String validationId,
    PrerequisiteStatus status, {
    String? blockedReason,
  });
}

/// Implementación de Supabase para PrerequisiteRepository
class PrerequisiteRepository implements IPrerequisiteRepository {
  final SupabaseClient _client;
  static const String _formsTable = 'prerequisite_forms';
  static const String _validationsTable = 'prerequisite_validations';

  PrerequisiteRepository(this._client);

  @override
  Future<List<PrerequisiteForm>> getByCategory(String visaCategoryCode) async {
    final response = await _client
        .from(_formsTable)
        .select()
        .eq('visa_category_code', visaCategoryCode)
        .eq('is_active', true)
        .order('order_index');

    return (response as List)
        .map((json) => PrerequisiteForm.fromJson(json))
        .toList();
  }

  @override
  Future<PrerequisiteForm?> getById(String id) async {
    final response = await _client
        .from(_formsTable)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return PrerequisiteForm.fromJson(response);
  }

  @override
  Future<List<PrerequisiteValidation>> getValidationsForApplication(
    String applicationId,
  ) async {
    final response = await _client
        .from(_validationsTable)
        .select()
        .eq('application_id', applicationId);

    return (response as List)
        .map((json) => PrerequisiteValidation.fromJson(json))
        .toList();
  }

  @override
  Future<PrerequisiteValidation> saveValidation(
    PrerequisiteValidation validation,
  ) async {
    final response = await _client
        .from(_validationsTable)
        .upsert(validation.toJson())
        .select()
        .single();

    return PrerequisiteValidation.fromJson(response);
  }

  @override
  Future<void> updateValidationStatus(
    String validationId,
    PrerequisiteStatus status, {
    String? blockedReason,
  }) async {
    final updates = <String, dynamic>{
      'validation_status': status.value,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (blockedReason != null) {
      updates['blocked_reason'] = blockedReason;
    }

    if (status == PrerequisiteStatus.valid) {
      updates['validated_at'] = DateTime.now().toIso8601String();
    }

    await _client
        .from(_validationsTable)
        .update(updates)
        .eq('id', validationId);
  }
}
