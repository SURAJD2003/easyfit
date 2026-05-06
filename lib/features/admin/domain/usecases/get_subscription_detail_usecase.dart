import '../entities/subscription_entity.dart';
import '../repositories/admin_repository.dart';

class GetSubscriptionDetailUseCase {
  final AdminRepository repository;
  const GetSubscriptionDetailUseCase({required this.repository});

  Future<SubscriptionEntity> call({required String subId}) async {
    return await repository.getSubscriptionDetail(subId: subId);
  }
}