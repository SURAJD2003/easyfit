import '../repositories/admin_repository.dart';

class ActivateUserUseCase {
  final AdminRepository repository;
  const ActivateUserUseCase({required this.repository});

  Future<void> call({required String userId}) async {
    await repository.activateUser(userId: userId);
  }
}