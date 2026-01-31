import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_profile_provider.g.dart';

/// Fetches user profile data from Supabase.
/// Returns a Map of profile fields for use by ConsularRisk analysis.
@riverpod
Future<Map<String, dynamic>?> fetchUserProfile(Ref ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) {
    return null;
  }
  
  try {
    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    
    if (response == null) {
      // Return default profile for new users
      return {
        'user_id': user.id,
        'monthly_salary': 0,
        'employment_status': 'unknown',
        'marital_status': 'unknown',
        'has_children': false,
        'owns_property': false,
        'passport_verified': false,
        'bank_statements_verified': false,
        'employment_letter_verified': false,
        'previous_visas_count': 0,
        'oecd_countries_visited': 0,
        'intended_stay_days': 14,
        'travel_purpose': 'tourism',
      };
    }
    
    return response;
  } catch (e) {
    // Return default profile on error
    return {
      'user_id': user.id,
      'monthly_salary': 0,
      'employment_status': 'unknown',
    };
  }
}
