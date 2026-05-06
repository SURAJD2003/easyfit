import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';

class GetAllUsersUseCase {
  final AdminRepository repository;
  const GetAllUsersUseCase({required this.repository});

  Future<List<AdminUserEntity>> call() async {
    return await repository.getAllUsers();
  }
}