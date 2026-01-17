import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Application state from Supabase for the current user.
/// Used by risk audit and other features that need user's form data.
class UserApplication {
  final String? id;
  final String status;
  final int step;
  final Map<String, dynamic> formData;
  final int simulatorScore;
  final String? visaType;

  const UserApplication({
    this.id,
    this.status = 'draft',
    this.step = 1,
    this.formData = const {},
    this.simulatorScore = 50,
    this.visaType,
  });

  /// Calculate age from form_data['dob'] if available
  String? get age {
    final dob = formData['dob'] as String?;
    if (dob == null) return null;
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    } catch (_) {
      return null;
    }
  }

  /// Check if user has strong ties (employment, property, family)
  bool get hasStrongTies {
    final occupation = formData['occupation'] as String?;
    final employer = formData['employer'] as String?;
    final maritalStatus = formData['maritalStatus'] as String?;
    
    // Has ties if employed or married
    return (occupation != null && occupation.isNotEmpty) ||
           (employer != null && employer.isNotEmpty) ||
           (maritalStatus != null && 
            maritalStatus.toLowerCase().contains('married'));
  }

  /// Check if user has previous travel history
  bool get hasTravelHistory {
    final previousTravel = formData['hasPreviousTravel'] as String?;
    return previousTravel != null && 
           previousTravel.isNotEmpty && 
           !previousTravel.toLowerCase().contains('no');
  }

  factory UserApplication.fromJson(Map<String, dynamic> json) {
    return UserApplication(
      id: json['id'] as String?,
      status: json['status'] as String? ?? 'draft',
      step: json['step'] as int? ?? 1,
      formData: json['form_data'] as Map<String, dynamic>? ?? {},
      simulatorScore: json['simulator_score'] as int? ?? 50,
      visaType: json['service_tier'] as String?,
    );
  }
}

/// Provider that fetches the current user's active application from Supabase
final userApplicationProvider = FutureProvider<UserApplication?>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) return null;

  final response = await supabase
      .from('applications')
      .select()
      .eq('user_id', userId)
      .order('updated_at', ascending: false)
      .limit(1)
      .maybeSingle();

  if (response == null) return null;
  
  return UserApplication.fromJson(response);
});

/// Provider that saves/updates the user's quick check data
class QuickCheckNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _supabase;

  QuickCheckNotifier(this._supabase) : super(const AsyncData(null));

  Future<void> saveQuickCheck({
    required String visaType,
    required String? ds160Code,
    required bool hasDs160,
  }) async {
    state = const AsyncLoading();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      // Update or create application with quick check data
      await _supabase.from('applications').upsert({
        'user_id': userId,
        'service_tier': visaType,
        'ds160_confirmation_number': ds160Code,
        'form_data': {
          'visaType': visaType,
          'hasDs160': hasDs160,
        },
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final quickCheckNotifierProvider =
    StateNotifierProvider<QuickCheckNotifier, AsyncValue<void>>((ref) {
  return QuickCheckNotifier(ref.watch(supabaseClientProvider));
});
