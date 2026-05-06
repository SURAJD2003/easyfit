import '../repositories/admin_repository.dart';

class ApproveSubscriptionUseCase {
  final AdminRepository repository;
  const ApproveSubscriptionUseCase({required this.repository});

  Future<void> call({required String subId}) async {
    await repository.approveSubscription(subId: subId);
  }
}