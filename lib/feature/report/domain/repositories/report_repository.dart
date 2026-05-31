import 'package:dartz/dartz.dart';
import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/feature/report/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, ReportEntity>> submitReport({
    required String userId,
    required ReportType reportType,
    String? targetId,
    String? targetName,
    required ReportReason reason,
    required String description,
  });

  Future<Either<Failure, List<ReportEntity>>> getReportHistory({
    required String userId,
  });

  Future<Either<Failure, List<ReportEntity>>> getReportsByType({
    required String userId,
    required ReportType reportType,
  });
}
