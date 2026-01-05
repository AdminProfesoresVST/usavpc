import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/payments/domain/entities/service_plan.dart';
import 'package:mobile/features/payments/domain/repositories/payments_repository.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  // In a real app, this would inject SupabaseClient
  // final SupabaseClient _supabase; 

  @override
  Future<List<ServicePlan>> getServicePlans() async {
    // SIMULATING DB CALL - TO BE REPLACED WITH SUPABASE SELECT
    // await _supabase.from('plans').select();
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    
    return [
      const ServicePlan(
        id: 'diy',
        title: 'US Visa Strategy Review (DIY)',
        price: 39.00,
        description: 'Comprehensive analysis and VisaScore™ report. Best for self-starters.',
        isPopular: true,
      ),
      const ServicePlan(
        id: 'full',
        title: 'US Visa Full Service',
        price: 99.00,
        description: 'Complete application management and priority review.',
      ),
       const ServicePlan(
        id: 'simulator',
        title: 'AI Interview Simulator',
        price: 29.00,
        description: '30 Days of unlimited practice with our AI Officer.',
      ),
    ];
  }
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepositoryImpl();
});
