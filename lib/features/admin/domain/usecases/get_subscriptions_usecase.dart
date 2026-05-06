import '../entities/subscription_entity.dart';
import '../repositories/admin_repository.dart';

class GetSubscriptionsUseCase {
  final AdminRepository repository;
  const GetSubscriptionsUseCase({required this.repository});

  Future<List<SubscriptionEntity>> call() async {
    return await repository.getSubscriptions();
  }
}