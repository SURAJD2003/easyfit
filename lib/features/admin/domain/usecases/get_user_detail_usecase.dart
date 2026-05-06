import '../entities/admin_user_entity.dart';
import '../repositories/admin_repository.dart';

class GetUserDetailUseCase {
  final AdminRepository repository;
  const GetUserDetailUseCase({required this.repository});

  Future<AdminUserEntity> call({required String userId}) async {
    return await repository.getUserDetail(userId: userId);
  }
}