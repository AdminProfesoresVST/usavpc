import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';

import 'auth_repository_test.mocks.dart';

// We mock SupabaseClient and GoTrueClient (Auth)
// Since SupabaseClient delegates to auth, we need to mock that chain properly or just mock the dependencies deeply.
// Mocking Supabase is notoriously hard because of deep nesting.
// Better to mock the underlying interaction or use fake_supabase if available, but for now we try basic mocking.

@GenerateMocks([SupabaseClient, GoTrueClient, LocalAuthentication])
void main() {
  late AuthRepositoryImpl authRepository;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockLocalAuthentication mockLocalAuth;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockLocalAuth = MockLocalAuthentication();

    // Link auth getter
    when(mockSupabase.auth).thenReturn(mockAuth);

    authRepository = AuthRepositoryImpl(
      supabase: mockSupabase,
      localAuth: mockLocalAuth,
    );
  });

  test('signIn calls supabase.auth.signInWithPassword', () async {
    // Stub
    when(mockAuth.signInWithPassword(email: 'test@test.com', password: 'pass'))
        .thenAnswer((_) async => AuthResponse(
              session: Session(
                accessToken: '123',
                tokenType: 'bearer',
                user: User(id: '123', appMetadata: {}, userMetadata: {}, aud: 'authenticated', createdAt: ''),
              ),
              user: User(id: '123', appMetadata: {}, userMetadata: {}, aud: 'authenticated', createdAt: ''),
            ));

    await authRepository.signIn(email: 'test@test.com', password: 'pass');

    verify(mockAuth.signInWithPassword(email: 'test@test.com', password: 'pass')).called(1);
  });
  
  test('biometric auth returns true on success', () async {
    when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
    when(mockLocalAuth.authenticate(
      localizedReason: anyNamed('localizedReason'),
    )).thenAnswer((_) async => true);
    
    final result = await authRepository.authenticateBiometric();
    
    expect(result, true);
    verify(mockLocalAuth.authenticate(localizedReason: anyNamed('localizedReason'))).called(1);
  });
}
