import '../repositories/admin_repository.dart';

class GrantSubscriptionUseCase {
  final AdminRepository repository;

  GrantSubscriptionUseCase({required this.repository});

  Future<void> call({
    required String userId,
    required String planId,
    String? expiryDate,
    String? reason,
  }) async {
    return await repository.grantSubscription(
      userId: userId,
      planId: planId,
      expiryDate: expiryDate,
      reason: reason,
    );
  }
}
