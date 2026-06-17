import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/report/data/config/report_config.dart';
import 'package:dartz/dartz.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ReportConfig>> getReportConfig();
  Future<Either<Failure, Map<String, List<dynamic>>>> getMyReports();
  Future<Either<Failure, Unit>> createAppReport(
      {required String reportType,
      required String title,
      required String content});
  Future<Either<Failure, Unit>> createUserReport(
      {required String reportedUsername, required String content});
}
