import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/social_media_profile.dart';

/// Repository para perfiles de redes sociales
abstract class ISocialMediaAuditRepository {
  Future<List<SocialMediaProfile>> getByApplication(String applicationId);
  Future<SocialMediaProfile> create(SocialMediaProfile profile);
  Future<SocialMediaProfile> update(SocialMediaProfile profile);
  Future<void> delete(String profileId);
  Future<void> updateAuditStatus(
    String profileId,
    AuditStatus status, {
    Map<String, dynamic>? discrepancyDetails,
  });
}

/// Implementación de Supabase para SocialMediaAuditRepository
class SocialMediaAuditRepository implements ISocialMediaAuditRepository {
  final SupabaseClient _client;
  static const String _tableName = 'social_media_profiles';

  SocialMediaAuditRepository(this._client);

  @override
  Future<List<SocialMediaProfile>> getByApplication(String applicationId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('application_id', applicationId)
        .order('created_at');

    return (response as List)
        .map((json) => SocialMediaProfile.fromJson(json))
        .toList();
  }

  @override
  Future<SocialMediaProfile> create(SocialMediaProfile profile) async {
    final response = await _client
        .from(_tableName)
        .insert(profile.toJson())
        .select()
        .single();

    return SocialMediaProfile.fromJson(response);
  }

  @override
  Future<SocialMediaProfile> update(SocialMediaProfile profile) async {
    final response = await _client
        .from(_tableName)
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();

    return SocialMediaProfile.fromJson(response);
  }

  @override
  Future<void> delete(String profileId) async {
    await _client.from(_tableName).delete().eq('id', profileId);
  }

  @override
  Future<void> updateAuditStatus(
    String profileId,
    AuditStatus status, {
    Map<String, dynamic>? discrepancyDetails,
  }) async {
    final updates = <String, dynamic>{
      'audit_status': status.value,
      'audited_at': DateTime.now().toIso8601String(),
    };

    if (discrepancyDetails != null) {
      updates['discrepancy_details'] = discrepancyDetails;
    }

    await _client.from(_tableName).update(updates).eq('id', profileId);
  }
}

/// Servicio de auditoría de empleo LinkedIn vs DS-160
class EmploymentAuditService {
  /// Compara datos de empleo del formulario DS-160 con datos de LinkedIn
  List<EmploymentDiscrepancy> compareEmployment({
    required List<Map<String, dynamic>> ds160Employment,
    required List<Map<String, dynamic>> linkedInEmployment,
  }) {
    final discrepancies = <EmploymentDiscrepancy>[];

    for (final ds160Job in ds160Employment) {
      final companyName = ds160Job['company_name'] as String?;
      if (companyName == null) continue;

      // Buscar coincidencia en LinkedIn
      final linkedInMatch = linkedInEmployment.firstWhere(
        (job) => _fuzzyMatch(
          job['company_name'] as String? ?? '',
          companyName,
        ),
        orElse: () => <String, dynamic>{},
      );

      if (linkedInMatch.isEmpty) {
        // Trabajo en DS-160 no encontrado en LinkedIn
        discrepancies.add(EmploymentDiscrepancy(
          type: 'missing_job',
          ds160Data: ds160Job,
          socialData: null,
          message: 'Job "$companyName" in DS-160 not found on LinkedIn',
        ));
      } else {
        // Verificar fechas
        final ds160Start = ds160Job['start_date'] as String?;
        final ds160End = ds160Job['end_date'] as String?;
        final liStart = linkedInMatch['start_date'] as String?;
        final liEnd = linkedInMatch['end_date'] as String?;

        if (ds160Start != liStart || ds160End != liEnd) {
          discrepancies.add(EmploymentDiscrepancy(
            type: 'date_mismatch',
            ds160Data: ds160Job,
            socialData: linkedInMatch,
            message: 'Employment dates for "$companyName" do not match',
          ));
        }

        // Verificar título
        final ds160Title = ds160Job['job_title'] as String?;
        final liTitle = linkedInMatch['job_title'] as String?;
        if (ds160Title != null && liTitle != null && !_fuzzyMatch(ds160Title, liTitle)) {
          discrepancies.add(EmploymentDiscrepancy(
            type: 'title_mismatch',
            ds160Data: ds160Job,
            socialData: linkedInMatch,
            message: 'Job title mismatch for "$companyName": DS-160 says "$ds160Title", LinkedIn says "$liTitle"',
          ));
        }
      }
    }

    // Verificar trabajos en LinkedIn que no están en DS-160
    for (final liJob in linkedInEmployment) {
      final companyName = liJob['company_name'] as String?;
      if (companyName == null) continue;

      final ds160Match = ds160Employment.any(
        (job) => _fuzzyMatch(
          job['company_name'] as String? ?? '',
          companyName,
        ),
      );

      if (!ds160Match) {
        discrepancies.add(EmploymentDiscrepancy(
          type: 'extra_job',
          ds160Data: null,
          socialData: liJob,
          message: 'Job "$companyName" on LinkedIn not declared in DS-160',
        ));
      }
    }

    return discrepancies;
  }

  /// Comparación fuzzy de strings
  bool _fuzzyMatch(String a, String b) {
    final normalizedA = a.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final normalizedB = b.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    if (normalizedA == normalizedB) return true;
    if (normalizedA.contains(normalizedB) || normalizedB.contains(normalizedA)) {
      return true;
    }
    
    // Calcular similitud básica
    final longer = normalizedA.length > normalizedB.length ? normalizedA : normalizedB;
    final shorter = normalizedA.length > normalizedB.length ? normalizedB : normalizedA;
    
    if (longer.isEmpty) return true;
    
    int matches = 0;
    for (int i = 0; i < shorter.length; i++) {
      if (i < longer.length && shorter[i] == longer[i]) {
        matches++;
      }
    }
    
    return matches / longer.length > 0.7;
  }
}
