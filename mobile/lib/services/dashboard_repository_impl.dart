import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/models/dashboard_data.dart';
import 'package:mobile/services/dashboard_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Production-ready dashboard repository that fetches real data from Supabase.
/// Migration: 2026-01-17 - Replaced hardcoded mock data with real DB calls.
class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseClient _supabase;

  DashboardRepositoryImpl(this._supabase);

  @override
  Future<DashboardData> getDashboardData() async {
    // Get current user's application
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      // Return default state for non-authenticated users
      return const DashboardData(
        status: 'NOT_STARTED',
        progress: 0.0,
        lastEdited: 'N/A',
        nextSteps: [
          const DashboardAction(
            title: 'Iniciar Solicitud',
            subtitle: 'Comienza tu proceso de visa',
            iconCode: 'start',
          ),
          const DashboardAction(
            title: 'Verificar Restricciones',
            subtitle: 'Chequeo de Travel Ban 2026',
            iconCode: 'travel_ban',
          ),
          const DashboardAction(
            title: 'Calculadora de Costos',
            subtitle: 'Estimación completa de tarifas',
            iconCode: 'calculator',
          ),
        ],
      );
    }

    // PRODUCTION: Real database query
    final response = await _supabase
        .from('applications')
        .select('status, step, updated_at, has_strategy_check')
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return const DashboardData(
        status: 'NOT_STARTED',
        progress: 0.0,
        lastEdited: 'N/A',
        nextSteps: [
          const DashboardAction(
            title: 'Iniciar Solicitud',
            subtitle: 'Comienza tu proceso de visa',
            iconCode: 'start',
          ),
          const DashboardAction(
            title: 'Verificar Restricciones',
            subtitle: 'Chequeo de Travel Ban 2026',
            iconCode: 'travel_ban',
          ),
          const DashboardAction(
            title: 'Calculadora de Costos',
            subtitle: 'Estimación completa de tarifas',
            iconCode: 'calculator',
          ),
        ],
      );
    }

    // Parse application data
    final status = response['status'] as String? ?? 'draft';
    final step = response['step'] as int? ?? 1;
    final updatedAt = response['updated_at'] as String?;
    
    // Calculate progress based on step (assuming 5 total steps)
    final progress = (step / 5.0).clamp(0.0, 1.0);
    
    // Format last edited time
    String lastEdited = 'N/A';
    if (updatedAt != null) {
      final date = DateTime.parse(updatedAt);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) {
        lastEdited = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        lastEdited = '${diff.inHours}h ago';
      } else {
        lastEdited = '${diff.inDays}d ago';
      }
    }

    // Determine next steps based on current status
    List<DashboardAction> nextSteps = [];
    if (status == 'draft') {
      if (response['has_strategy_check'] != true) {
        nextSteps.add(const DashboardAction(
          title: 'Verificación de Estrategia',
          subtitle: 'Análisis de riesgo con IA',
          iconCode: 'assessment',
        ));
      }
      nextSteps.add(const DashboardAction(
        title: 'Subir Documentos',
        subtitle: 'Pasaporte y foto requeridos',
        iconCode: 'upload_file',
      ));
    } else if (status == 'pending_payment') {
      nextSteps.add(const DashboardAction(
        title: 'Completar Pago',
        subtitle: 'Selecciona tu plan',
        iconCode: 'payment',
      ));
    }
    
    // Always show utility tools
    nextSteps.add(const DashboardAction(
      title: 'Verificar Restricciones',
      subtitle: 'Chequeo de Travel Ban 2026',
      iconCode: 'travel_ban',
    ));
    nextSteps.add(const DashboardAction(
      title: 'Calculadora de Costos',
      subtitle: 'Estimación completa de tarifas',
      iconCode: 'calculator',
    ));

    return DashboardData(
      status: status.toUpperCase(),
      progress: progress,
      lastEdited: lastEdited,
      nextSteps: nextSteps,
    );
  }

  @override
  Future<Map<String, dynamic>> getProfileData() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user');

    final app = await _supabase
        .from('applications')
        .select('form_data, status, passport_image_url, simulator_history, simulator_score, ds160_payload, ds160_confirmation_number')
        .eq('user_id', userId)
        .maybeSingle();

    final profile = await _supabase
        .from('profiles')
        .select('id, email, phone, role')
        .eq('id', userId)
        .maybeSingle();

    return {
      'app': app,
      'profile': profile,
      'email': _supabase.auth.currentUser?.email,
    };
  }

  @override
  Future<void> updateApplication(Map<String, dynamic> updates) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user');

    await _supabase.from('applications').update(updates).eq('user_id', userId);
  }

  @override
  Future<void> createApplication(Map<String, dynamic> data) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('No user');

    // Ensure user_id is set in data
    final dataToSave = Map<String, dynamic>.from(data);
    dataToSave['user_id'] = userId;

    await _supabase.from('applications').insert(dataToSave);
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(supabaseClientProvider));
});
