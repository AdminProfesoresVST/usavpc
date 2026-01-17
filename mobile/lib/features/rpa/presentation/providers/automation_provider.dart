import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// RPA Automation state
class AutomationState {
  final double progress;
  final List<String> logs;
  final Map<String, dynamic>? formData;
  final bool isComplete;
  final String? error;

  const AutomationState({
    this.progress = 0.0,
    this.logs = const [],
    this.formData,
    this.isComplete = false,
    this.error,
  });

  AutomationState copyWith({
    double? progress,
    List<String>? logs,
    Map<String, dynamic>? formData,
    bool? isComplete,
    String? error,
  }) {
    return AutomationState(
      progress: progress ?? this.progress,
      logs: logs ?? this.logs,
      formData: formData ?? this.formData,
      isComplete: isComplete ?? this.isComplete,
      error: error,
    );
  }
}

/// RPA Notifier that manages automation state and fetches user data
class AutomationNotifier extends StateNotifier<AutomationState> {
  final SupabaseClient _supabase;

  AutomationNotifier(this._supabase) : super(const AutomationState());

  /// Load user's form data from Supabase to prepare for automation
  Future<void> loadUserData() async {
    try {
      _addLog('Conectando a base de datos...');
      state = state.copyWith(progress: 0.05);

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      _addLog('Cargando datos de solicitud...');
      state = state.copyWith(progress: 0.1);

      final response = await _supabase
          .from('applications')
          .select('form_data, ds160_payload')
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        throw Exception('No se encontró solicitud activa');
      }

      // Merge form_data and ds160_payload
      final formData = <String, dynamic>{};
      if (response['form_data'] != null) {
        formData.addAll(Map<String, dynamic>.from(response['form_data']));
      }
      if (response['ds160_payload'] != null) {
        formData.addAll(Map<String, dynamic>.from(response['ds160_payload']));
      }

      if (formData.isEmpty) {
        throw Exception('No hay datos de formulario para automatizar');
      }

      _addLog('Datos cargados: ${formData.keys.length} campos');
      state = state.copyWith(
        progress: 0.15,
        formData: formData,
      );

      _addLog('Sistema listo para automatización');
      state = state.copyWith(progress: 0.2);

    } catch (e) {
      state = state.copyWith(error: e.toString());
      _addLog('ERROR: $e');
    }
  }

  /// Add a log entry
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    state = state.copyWith(
      logs: [...state.logs, '[$timestamp] $message'],
    );
  }

  /// Update progress after WebView injection
  void updateProgress(double progress, String message) {
    _addLog(message);
    state = state.copyWith(progress: progress);
  }

  /// Mark automation as complete
  void markComplete(String message) {
    _addLog(message);
    state = state.copyWith(
      progress: 1.0,
      isComplete: true,
    );
  }

  /// Record error
  void recordError(String error) {
    _addLog('ERROR: $error');
    state = state.copyWith(error: error);
  }

  /// Save DS-160 confirmation number back to database
  Future<void> saveConfirmationNumber(String confirmationNumber) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('applications').update({
        'ds160_confirmation_number': confirmationNumber,
        'status': 'ds160_complete',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      _addLog('Número de confirmación guardado: $confirmationNumber');
    } catch (e) {
      _addLog('Error guardando confirmación: $e');
    }
  }
}

final automationProvider =
    StateNotifierProvider<AutomationNotifier, AutomationState>((ref) {
  return AutomationNotifier(ref.watch(supabaseClientProvider));
});
