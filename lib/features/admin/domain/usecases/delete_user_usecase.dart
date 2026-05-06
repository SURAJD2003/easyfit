import '../repositories/admin_repository.dart';

class DeleteUserUseCase {
  final AdminRepository repository;
  const DeleteUserUseCase({required this.repository});

  Future<void> call({required String userId}) async {
    await repository.deleteUser(userId: userId);
  }
}