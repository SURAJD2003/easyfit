import '../repositories/admin_repository.dart';

class RejectSubscriptionUseCase {
  final AdminRepository repository;
  const RejectSubscriptionUseCase({required this.repository});

  Future<void> call({required String subId}) async {
    await repository.rejectSubscription(subId: subId);
  }
}