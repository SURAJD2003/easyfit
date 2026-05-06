import '../repositories/admin_repository.dart';

class LoginUseCase {
  final AdminRepository repository;
  const LoginUseCase({required this.repository});

  Future<String> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}