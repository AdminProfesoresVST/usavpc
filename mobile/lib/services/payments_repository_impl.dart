import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/models/service_plan.dart';
import 'package:mobile/services/payments_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Production-ready payments repository that fetches real data from Supabase.
/// Migration: 2026-01-17 - Replaced hardcoded mock data with real DB calls.
class PaymentsRepositoryImpl implements PaymentsRepository {
  final SupabaseClient _supabase;

  PaymentsRepositoryImpl(this._supabase);

  @override
  Future<List<ServicePlan>> getServicePlans() async {
    // PRODUCTION: Real database query
    final response = await _supabase
        .from('plans')
        .select('id, title, price, description, is_popular')
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response as List<dynamic>)
        .map((json) => ServicePlan.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepositoryImpl(ref.watch(supabaseClientProvider));
});
