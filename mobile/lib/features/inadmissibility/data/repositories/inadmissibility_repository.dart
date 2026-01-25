import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inadmissibility_flag.dart';

/// Repository para alertas de inadmisibilidad
abstract class IInadmissibilityRepository {
  Future<List<InadmissibilityFlag>> getByApplication(String applicationId);
  Future<InadmissibilityFlag> create(InadmissibilityFlag flag);
  Future<void> acknowledge(String flagId);
  Future<void> deleteByApplication(String applicationId);
}

/// Implementación de Supabase para InadmissibilityRepository
class InadmissibilityRepository implements IInadmissibilityRepository {
  final SupabaseClient _client;
  static const String _tableName = 'inadmissibility_flags';

  InadmissibilityRepository(this._client);

  @override
  Future<List<InadmissibilityFlag>> getByApplication(String applicationId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('application_id', applicationId)
        .order('severity', ascending: false);

    return (response as List)
        .map((json) => InadmissibilityFlag.fromJson(json))
        .toList();
  }

  @override
  Future<InadmissibilityFlag> create(InadmissibilityFlag flag) async {
    final response = await _client
        .from(_tableName)
        .insert(flag.toJson())
        .select()
        .single();

    return InadmissibilityFlag.fromJson(response);
  }

  @override
  Future<void> acknowledge(String flagId) async {
    await _client
        .from(_tableName)
        .update({
          'user_acknowledged': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', flagId);
  }

  @override
  Future<void> deleteByApplication(String applicationId) async {
    await _client
        .from(_tableName)
        .delete()
        .eq('application_id', applicationId);
  }
}

/// Detector de inadmisibilidad basado en datos del formulario
class InadmissibilityDetector {
  /// Analiza datos del formulario y detecta posibles causales de inadmisibilidad
  List<InadmissibilityFlag> analyzeFormData({
    required String applicationId,
    required Map<String, dynamic> formData,
  }) {
    final flags = <InadmissibilityFlag>[];

    // 1. PRESENCIA ILEGAL
    final previousStayDays = formData['previous_us_stay_days'] as int?;
    if (previousStayDays != null && previousStayDays > 180) {
      final is10YearBar = previousStayDays > 365;
      flags.add(InadmissibilityFlag(
        id: '', // Se genera en insert
        applicationId: applicationId,
        flagType: InadmissibilityType.unlawfulPresence,
        severity: is10YearBar ? Severity.critical : Severity.high,
        detectedFromField: 'previous_us_stay_days',
        detectedValue: previousStayDays.toString(),
        suggestedWaiver: 'I-601',
        waiverNotes: is10YearBar
            ? '10-year bar applies. Waiver required from USCIS.'
            : '3-year bar applies. Consider I-601 waiver.',
        createdAt: DateTime.now(),
      ));
    }

    // 2. OVERSTAY PREVIO
    final hadOverstay = formData['previous_visa_overstay'] as bool?;
    if (hadOverstay == true) {
      flags.add(InadmissibilityFlag(
        id: '',
        applicationId: applicationId,
        flagType: InadmissibilityType.visaOverstay,
        severity: Severity.high,
        detectedFromField: 'previous_visa_overstay',
        suggestedWaiver: 'I-601',
        waiverNotes: 'Prior overstay may trigger 3 or 10 year bar.',
        createdAt: DateTime.now(),
      ));
    }

    // 3. ANTECEDENTES PENALES
    final hasCriminalRecord = formData['has_criminal_record'] as bool?;
    if (hasCriminalRecord == true) {
      flags.add(InadmissibilityFlag(
        id: '',
        applicationId: applicationId,
        flagType: InadmissibilityType.criminalRecord,
        severity: Severity.critical,
        detectedFromField: 'has_criminal_record',
        suggestedWaiver: 'I-601',
        waiverNotes: 'Consult immigration attorney. Some crimes are waivable.',
        createdAt: DateTime.now(),
      ));
    }

    // 4. RESIDENTE QUE RETORNA
    final isReturningResident = formData['is_returning_lpr'] as bool?;
    final timeOutside = formData['time_outside_usa_months'] as int?;
    if (isReturningResident == true && timeOutside != null && timeOutside > 12) {
      flags.add(InadmissibilityFlag(
        id: '',
        applicationId: applicationId,
        flagType: InadmissibilityType.returningResident,
        severity: timeOutside > 24 ? Severity.high : Severity.medium,
        detectedFromField: 'time_outside_usa_months',
        detectedValue: timeOutside.toString(),
        suggestedWaiver: 'DS-117',
        waiverNotes: 'Apply for Returning Resident Visa (SB-1).',
        createdAt: DateTime.now(),
      ));
    }

    // 5. RIESGO DE CARGA PÚBLICA
    final income = formData['annual_income_usd'] as int?;
    final householdSize = formData['household_size'] as int? ?? 1;
    if (income != null) {
      final povertyLine = _getPovertyGuideline(householdSize);
      final threshold = (povertyLine * 1.25).round();
      
      if (income < threshold) {
        flags.add(InadmissibilityFlag(
          id: '',
          applicationId: applicationId,
          flagType: InadmissibilityType.publicCharge,
          severity: Severity.medium,
          detectedFromField: 'annual_income_usd',
          detectedValue: income.toString(),
          suggestedWaiver: null,
          waiverNotes: 'Income below 125% poverty guideline (\$$threshold). Requires I-864 with co-sponsor.',
          createdAt: DateTime.now(),
        ));
      }
    }

    return flags;
  }

  int _getPovertyGuideline(int householdSize) {
    // 2026 Federal Poverty Guidelines (estimated)
    const baseAmount = 15060;
    const perPersonAdd = 5380;
    return baseAmount + (perPersonAdd * (householdSize - 1));
  }
}
