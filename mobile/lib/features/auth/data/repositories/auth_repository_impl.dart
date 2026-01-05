import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/supabase_client.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  final LocalAuthentication _localAuth;

  AuthRepositoryImpl({
    required SupabaseClient supabase,
    required LocalAuthentication localAuth,
  })  : _supabase = supabase,
        _localAuth = localAuth;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  @override
  Stream<String?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) => event.session?.user.id);
  }

  @override
  Future<bool> authenticateBiometric() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    if (!canCheck) return false;
    
    return await _localAuth.authenticate(
      localizedReason: 'Scan to verify identity',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    supabase: ref.watch(supabaseClientProvider),
    localAuth: LocalAuthentication(),
  );
});
