import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/report/data/datasources/report_remote_datasource.dart';
import 'package:afiete/feature/report/data/models/report_config_model.dart';
import 'package:afiete/feature/report/domain/repositories/report_repository.dart';
import 'package:dartz/dartz.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ReportConfigModel>> getReportConfig() async {
    try {
      final config = await remoteDataSource.getReportConfig();
      return Right(config);
    } on ServerFailure catch (e) {
      return Left(
          ServerFailure(e.toString())); // تمرير الرسالة القادمة من السيرفر
    }
  }

  @override
  Future<Either<Failure, Map<String, List>>> getMyReports() async {
    try {
      final reportsMap = await remoteDataSource.getMyReports();
      return Right(reportsMap);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createAppReport(
      {required String reportType,
      required String title,
      required String content}) async {
    try {
      remoteDataSource.createAppReport(reportType, title, content);
      return const Right(unit);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createUserReport(
      {required String reportedUsername, required String content}) async {
    try {
      remoteDataSource.createUserReport(reportedUsername, content);
      return const Right(unit);
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
