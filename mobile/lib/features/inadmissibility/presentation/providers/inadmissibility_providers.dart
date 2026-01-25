import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../visa/presentation/providers/visa_providers.dart';
import '../data/models/inadmissibility_flag.dart';
import '../data/repositories/inadmissibility_repository.dart';

/// Provider del repository de inadmisibilidad
final inadmissibilityRepositoryProvider = Provider<IInadmissibilityRepository>((ref) {
  return InadmissibilityRepository(ref.watch(supabaseClientProvider));
});

/// Provider del detector de inadmisibilidad
final inadmissibilityDetectorProvider = Provider<InadmissibilityDetector>((ref) {
  return InadmissibilityDetector();
});

/// Provider de alertas por aplicación
final inadmissibilityFlagsProvider = FutureProvider.family<List<InadmissibilityFlag>, String>((ref, applicationId) async {
  final repository = ref.watch(inadmissibilityRepositoryProvider);
  return repository.getByApplication(applicationId);
});

/// Provider de análisis de formulario
final analyzeFormProvider = Provider.family<List<InadmissibilityFlag>, AnalyzeFormParams>((ref, params) {
  final detector = ref.watch(inadmissibilityDetectorProvider);
  return detector.analyzeFormData(
    applicationId: params.applicationId,
    formData: params.formData,
  );
});

/// Parámetros para análisis de formulario
class AnalyzeFormParams {
  final String applicationId;
  final Map<String, dynamic> formData;

  const AnalyzeFormParams({
    required this.applicationId,
    required this.formData,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyzeFormParams &&
        other.applicationId == applicationId;
  }

  @override
  int get hashCode => applicationId.hashCode;
}

/// Estado de alertas reconocidas
final acknowledgedFlagsProvider = StateProvider<Set<String>>((ref) => {});
