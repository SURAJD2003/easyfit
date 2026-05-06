import '../repositories/admin_repository.dart';

class SegmentNotificationUseCase {
  final AdminRepository repository;
  const SegmentNotificationUseCase({required this.repository});

  Future<void> call({
    required String title,
    required String body,
    required String segment,
  }) async {
    await repository.segmentNotification(
      title: title,
      body: body,
      segment: segment,
    );
  }
}