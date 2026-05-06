import '../repositories/admin_repository.dart';

class BroadcastNotificationUseCase {
  final AdminRepository repository;
  const BroadcastNotificationUseCase({required this.repository});

  Future<void> call({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    await repository.broadcastNotification(
        title: title, body: body, imageUrl: imageUrl);
  }
}