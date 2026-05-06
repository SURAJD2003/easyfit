import '../entities/report_entity.dart';
import '../repositories/admin_repository.dart';

class GetReportsUseCase {
  final AdminRepository repository;
  const GetReportsUseCase({required this.repository});

  Future<ReportEntity> call({String? from, String? to}) async {
    return await repository.getReports(from: from, to: to);
  }
}