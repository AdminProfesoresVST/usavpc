abstract class AuthRepository {
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password});
  Future<void> signOut();
  Stream<String?> get authStateChanges;
  Future<bool> authenticateBiometric();
}
