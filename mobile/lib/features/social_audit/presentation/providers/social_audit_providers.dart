import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../visa/presentation/providers/visa_providers.dart';
import '../../data/models/social_media_profile.dart';
import '../../data/repositories/social_media_audit_repository.dart';

/// Provider del repository de auditoría de redes sociales
final socialMediaAuditRepositoryProvider = Provider<ISocialMediaAuditRepository>((ref) {
  return SocialMediaAuditRepository(ref.watch(supabaseClientProvider));
});

/// Provider del servicio de auditoría de empleo
final employmentAuditServiceProvider = Provider<EmploymentAuditService>((ref) {
  return EmploymentAuditService();
});

/// Provider de perfiles de redes sociales por aplicación
final socialMediaProfilesProvider = FutureProvider.family<List<SocialMediaProfile>, String>((ref, applicationId) async {
  final repository = ref.watch(socialMediaAuditRepositoryProvider);
  return repository.getByApplication(applicationId);
});

/// Parámetros para comparar empleo
class EmploymentComparisonParams {
  final List<Map<String, dynamic>> ds160Employment;
  final List<Map<String, dynamic>> linkedInEmployment;

  const EmploymentComparisonParams({
    required this.ds160Employment,
    required this.linkedInEmployment,
  });
}

/// Provider de comparación de empleo
final employmentComparisonProvider = Provider.family<List<EmploymentDiscrepancy>, EmploymentComparisonParams>((ref, params) {
  final service = ref.watch(employmentAuditServiceProvider);
  return service.compareEmployment(
    ds160Employment: params.ds160Employment,
    linkedInEmployment: params.linkedInEmployment,
  );
});
