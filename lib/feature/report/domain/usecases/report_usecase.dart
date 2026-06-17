import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/report/data/config/report_config.dart';
import 'package:afiete/feature/report/domain/repositories/report_repository.dart';
import 'package:dartz/dartz.dart';

class GetReportConfigUseCase {
  final ReportsRepository repository;
  GetReportConfigUseCase(this.repository);

  Future<Either<Failure, ReportConfig>> call() async =>
      await repository.getReportConfig();
}

class GetMyReportsUseCase {
  final ReportsRepository repository;
  GetMyReportsUseCase(this.repository);

  Future<Either<Failure, Map<String, List<dynamic>>>> call() async =>
      await repository.getMyReports();
}

class CreateAppReportUseCase {
  final ReportsRepository repository;
  CreateAppReportUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String reportType,
    required String title,
    required String content,
  }) async =>
      await repository.createAppReport(
        reportType: reportType,
        title: title,
        content: content,
      );
}

class CreateUserReportUseCase {
  final ReportsRepository repository;
  CreateUserReportUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String reportedUsername,
    required String content,
  }) async =>
      await repository.createUserReport(
        reportedUsername: reportedUsername,
        content: content,
      );
}
