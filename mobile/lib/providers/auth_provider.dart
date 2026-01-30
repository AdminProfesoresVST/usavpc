import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/services/auth_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signIn(email: email, password: password);
    });
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signUp(email: email, password: password);
    });
  }
  
  Future<void> signOut() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
  }
}

@riverpod
Stream<String?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
