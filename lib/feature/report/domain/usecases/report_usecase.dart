import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/report/domain/entities/report_config.dart';
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
    required String reason,
    required String description,
  }) async =>
      await repository.createAppReport(
        reason: reason,
        description: description,
      );
}

class CreateUserReportUseCase {
  final ReportsRepository repository;
  CreateUserReportUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String reportType,
    required String targetName,
    required String reason,
    required String description,
  }) async =>
      await repository.createUserReport(
        reportType: reportType,
        targetName: targetName,
        reason: reason,
        description: description,
      );
}
