import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/visa_fee.dart';

/// Repository para tarifas de visa
abstract class IVisaFeeRepository {
  Future<List<VisaFee>> getAll();
  Future<int?> getBaseFee(String visaCategoryCode);
  Future<int?> getReciprocityFee(String countryCode, String visaCategoryCode);
  Future<VisaFee?> getIntegrityFee();
  Future<VisaFee?> getSevisFee(String visaCategoryCode);
  Future<VisaFee?> getI94LandFee();
  Future<CostCalculation> calculateTotal({
    required String countryCode,
    required String visaCategoryCode,
    required int baseFee,
    bool crossingByLand = false,
    bool requiresSevis = false,
  });
  Future<void> saveCostCalculation(CostCalculation calculation);
}

/// Implementación de Supabase para VisaFeeRepository
class VisaFeeRepository implements IVisaFeeRepository {
  final SupabaseClient _client;
  static const String _feesTable = 'visa_fees';
  static const String _calculationsTable = 'cost_calculations';

  VisaFeeRepository(this._client);

  @override
  Future<List<VisaFee>> getAll() async {
    final response = await _client
        .from(_feesTable)
        .select()
        .eq('is_active', true);

    return (response as List)
        .map((json) => VisaFee.fromJson(json))
        .toList();
  }

  @override
  Future<int?> getBaseFee(String visaCategoryCode) async {
    final response = await _client
        .from(_feesTable)
        .select('amount_usd')
        .eq('fee_type', 'mrv_base')
        .eq('visa_category_code', visaCategoryCode)
        .eq('is_active', true)
        .maybeSingle();

    return response?['amount_usd'] as int?;
  }

  @override
  Future<int?> getReciprocityFee(String countryCode, String visaCategoryCode) async {
    final response = await _client
        .from(_feesTable)
        .select('amount_usd')
        .eq('fee_type', 'reciprocity')
        .eq('country_code', countryCode.toUpperCase())
        .eq('visa_category_code', visaCategoryCode)
        .eq('is_active', true)
        .maybeSingle();

    return response?['amount_usd'] as int?;
  }

  @override
  Future<VisaFee?> getIntegrityFee() async {
    final response = await _client
        .from(_feesTable)
        .select()
        .eq('fee_type', 'integrity_fee')
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return VisaFee.fromJson(response);
  }

  @override
  Future<VisaFee?> getSevisFee(String visaCategoryCode) async {
    final response = await _client
        .from(_feesTable)
        .select()
        .eq('fee_type', 'sevis_i901')
        .eq('visa_category_code', visaCategoryCode)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return VisaFee.fromJson(response);
  }

  @override
  Future<VisaFee?> getI94LandFee() async {
    final response = await _client
        .from(_feesTable)
        .select()
        .eq('fee_type', 'i94_land')
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;
    return VisaFee.fromJson(response);
  }

  @override
  Future<CostCalculation> calculateTotal({
    required String countryCode,
    required String visaCategoryCode,
    required int baseFee,
    bool crossingByLand = false,
    bool requiresSevis = false,
  }) async {
    final breakdown = <CostBreakdownItem>[];

    // 1. Tarifa base MRV
    breakdown.add(CostBreakdownItem(
      feeType: FeeType.mrvBase,
      amountUsd: baseFee,
      description: 'MRV Application Fee',
    ));

    // 2. Visa Integrity Fee ($250)
    final integrityFee = await getIntegrityFee();
    if (integrityFee != null) {
      breakdown.add(CostBreakdownItem(
        feeType: FeeType.integrityFee,
        amountUsd: integrityFee.amountUsd,
        description: 'Visa Integrity and Border Security Fee',
        isRefundable: integrityFee.isRefundable,
        refundConditions: integrityFee.refundConditions,
      ));
    }

    // 3. SEVIS Fee si aplica
    if (requiresSevis) {
      final sevisFee = await getSevisFee(visaCategoryCode);
      if (sevisFee != null) {
        breakdown.add(CostBreakdownItem(
          feeType: FeeType.sevisI901,
          amountUsd: sevisFee.amountUsd,
          description: 'SEVIS I-901 Fee',
          notes: 'Pay at fmjfee.com before interview',
        ));
      }
    }

    // 4. I-94 si cruza por tierra
    if (crossingByLand) {
      final i94Fee = await getI94LandFee();
      if (i94Fee != null) {
        breakdown.add(CostBreakdownItem(
          feeType: FeeType.i94Land,
          amountUsd: i94Fee.amountUsd,
          description: 'I-94 Land Border Fee',
        ));
      }
    }

    // 5. Reciprocidad por nacionalidad
    final reciprocity = await getReciprocityFee(countryCode, visaCategoryCode);
    if (reciprocity != null && reciprocity > 0) {
      breakdown.add(CostBreakdownItem(
        feeType: FeeType.reciprocity,
        amountUsd: reciprocity,
        description: 'Reciprocity Fee (${countryCode.toUpperCase()})',
        notes: 'Based on your nationality',
      ));
    }

    final total = breakdown
        .where((e) => !e.isOptional)
        .fold(0, (sum, e) => sum + e.amountUsd);

    return CostCalculation(
      breakdown: breakdown,
      totalUsd: total,
      countryCode: countryCode,
      visaCategory: visaCategoryCode,
      crossingByLand: crossingByLand,
      includesSevis: requiresSevis,
    );
  }

  @override
  Future<void> saveCostCalculation(CostCalculation calculation) async {
    await _client.from(_calculationsTable).insert(calculation.toJson());
  }
}
