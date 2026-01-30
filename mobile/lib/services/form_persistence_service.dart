import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormPersistenceService {
  final SupabaseClient _supabase;

  FormPersistenceService(this._supabase);

  /// Merges new fields into the existing `form_data` JSON column.
  /// Uses a Postgres function or deep merge logic if available, 
  /// otherwise fetches, merges locally, and upserts.
  Future<void> updateFormData(Map<String, dynamic> newFields) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // 1. Fetch current data
    final response = await _supabase
        .from('applications')
        .select('form_data')
        .eq('user_id', user.id)
        .maybeSingle();

    Map<String, dynamic> currentData = {};
    if (response != null && response['form_data'] != null) {
      currentData = Map<String, dynamic>.from(response['form_data'] as Map);
    }

    // 2. Merge new fields (overwriting existing keys)
    currentData.addAll(newFields);

    // 3. Save back
    await _supabase.from('applications').update({
      'form_data': currentData,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', user.id);
  }
}

final formPersistenceProvider = Provider<FormPersistenceService>((ref) {
  return FormPersistenceService(ref.watch(supabaseClientProvider));
});
