import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/visa_category.dart';
import '../../data/repositories/visa_category_repository.dart';
import '../../data/models/prerequisite_form.dart';
import '../../data/repositories/prerequisite_repository.dart';

/// Provider de Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider del repository de categorías de visa
final visaCategoryRepositoryProvider = Provider<IVisaCategoryRepository>((ref) {
  return VisaCategoryRepository(ref.watch(supabaseClientProvider));
});

/// Provider de prerequisite repository
final prerequisiteRepositoryProvider = Provider<IPrerequisiteRepository>((ref) {
  return PrerequisiteRepository(ref.watch(supabaseClientProvider));
});

/// Provider de todas las categorías de visa
final visaCategoriesProvider = FutureProvider<List<VisaCategory>>((ref) async {
  final repository = ref.watch(visaCategoryRepositoryProvider);
  return repository.getAll();
});

/// Provider de categorías por tipo
final visaCategoriesByTypeProvider = FutureProvider.family<List<VisaCategory>, VisaType>((ref, type) async {
  final repository = ref.watch(visaCategoryRepositoryProvider);
  return repository.getByType(type);
});

/// Provider de categoría por código
final visaCategoryByCodeProvider = FutureProvider.family<VisaCategory?, String>((ref, code) async {
  final repository = ref.watch(visaCategoryRepositoryProvider);
  return repository.getByCode(code);
});

/// Provider de categorías de no inmigrante (DS-160)
final nonImmigrantCategoriesProvider = FutureProvider<List<VisaCategory>>((ref) async {
  final repository = ref.watch(visaCategoryRepositoryProvider);
  return repository.getByFormEngine(FormEngine.ds160);
});

/// Provider de categorías de inmigrante (DS-260)
final immigrantCategoriesProvider = FutureProvider<List<VisaCategory>>((ref) async {
  final repository = ref.watch(visaCategoryRepositoryProvider);
  return repository.getByFormEngine(FormEngine.ds260);
});

/// Provider de prerrequisitos por categoría
final prerequisiteFormsProvider = FutureProvider.family<List<PrerequisiteForm>, String>((ref, categoryCode) async {
  final repository = ref.watch(prerequisiteRepositoryProvider);
  return repository.getByCategory(categoryCode);
});

/// Provider de validaciones de prerrequisitos por aplicación
final prerequisiteValidationsProvider = FutureProvider.family<List<PrerequisiteValidation>, String>((ref, applicationId) async {
  final repository = ref.watch(prerequisiteRepositoryProvider);
  return repository.getValidationsForApplication(applicationId);
});

/// Estado de categoría seleccionada
class SelectedVisaCategoryNotifier extends Notifier<VisaCategory?> {
  @override
  VisaCategory? build() => null;
  
  void set(VisaCategory? category) => state = category;
  void clear() => state = null;
}

final selectedVisaCategoryProvider = NotifierProvider<SelectedVisaCategoryNotifier, VisaCategory?>(
  SelectedVisaCategoryNotifier.new,
);

/// Estado de motor de formulario seleccionado
class SelectedFormEngineNotifier extends Notifier<FormEngine?> {
  @override
  FormEngine? build() => null;
  
  void set(FormEngine? engine) => state = engine;
  void clear() => state = null;
}

final selectedFormEngineProvider = NotifierProvider<SelectedFormEngineNotifier, FormEngine?>(
  SelectedFormEngineNotifier.new,
);
