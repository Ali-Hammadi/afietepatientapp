import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/report/data/datasources/report_remote_datasource.dart';
import 'package:afiete/feature/report/domain/entities/report_config.dart';
import 'package:afiete/feature/report/domain/repositories/report_repository.dart';
import 'package:dartz/dartz.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ReportConfig>> getReportConfig() async {
    try {
      final config = await remoteDataSource.getReportConfig();
      return Right(config);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<dynamic>>>> getMyReports() async {
    try {
      final reportsMap = await remoteDataSource.getMyReports();
      return Right(reportsMap);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createAppReport({
    required String reason,
    required String description,
  }) async {
    try {
      await remoteDataSource.createAppReport(
        reason: reason,
        description: description,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createUserReport({
    required String reportType,
    required String targetName,
    required String reason,
    required String description,
  }) async {
    try {
      await remoteDataSource.createUserReport(
        reportType: reportType,
        targetName: targetName,
        reason: reason,
        description: description,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
