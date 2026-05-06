import '../entities/analytics_entity.dart';
import '../repositories/admin_repository.dart';

class GetAnalyticsUseCase {
  final AdminRepository repository;
  const GetAnalyticsUseCase({required this.repository});

  Future<AnalyticsEntity> call() async {
    return await repository.getAnalytics();
  }
}