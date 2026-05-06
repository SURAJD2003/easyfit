import '../repositories/admin_repository.dart';

class DeactivateUserUseCase {
  final AdminRepository repository;
  const DeactivateUserUseCase({required this.repository});

  Future<void> call({required String userId, String? reason}) async {
    await repository.deactivateUser(userId: userId, reason: reason);
  }
}