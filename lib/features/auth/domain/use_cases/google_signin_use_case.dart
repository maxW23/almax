import '../../data/repos/auth_repository.dart';
import '../entities/user_entity.dart';

class GoogleSignInUseCase {
  final AuthRepository _authRepository;

  GoogleSignInUseCase({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  Future<UserEntity?> signIn() async {
    return await _authRepository.signInWithGoogle();
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }
}
