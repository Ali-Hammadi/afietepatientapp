import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/report/domain/entities/report_config.dart';
import 'package:dartz/dartz.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ReportConfig>> getReportConfig();

  Future<Either<Failure, Map<String, List<dynamic>>>> getMyReports();

  Future<Either<Failure, Unit>> createAppReport({
    required String reason,
    required String description,
  });

  Future<Either<Failure, Unit>> createUserReport({
    required String reportType,
    required String targetName,
    required String reason,
    required String description,
  });
}
