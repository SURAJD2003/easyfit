import '../repositories/admin_repository.dart';

class LogoutUseCase {
  final AdminRepository repository;
  const LogoutUseCase({required this.repository});

  Future<void> call() async {
    await repository.logout();
  }
}