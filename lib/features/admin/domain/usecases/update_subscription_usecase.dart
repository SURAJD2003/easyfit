import '../repositories/admin_repository.dart';

class UpdateSubscriptionUseCase {
  final AdminRepository repository;
  const UpdateSubscriptionUseCase({required this.repository});

  Future<void> call({
    required String subId,
    required Map<String, dynamic> data,
  }) async {
    await repository.updateSubscription(subId: subId, data: data);
  }
}