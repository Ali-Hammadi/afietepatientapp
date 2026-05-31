import 'package:dartz/dartz.dart';
import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/report/domain/entities/report_entity.dart';
import 'package:afietepatientapp/feature/report/domain/repositories/report_repository.dart';

class GetReportHistoryParams {
  final String userId;

  const GetReportHistoryParams({required this.userId});
}

class GetReportHistoryUseCase
    implements UseCase<List<ReportEntity>, GetReportHistoryParams> {
  final ReportRepository repository;

  const GetReportHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ReportEntity>>> call(
    GetReportHistoryParams params,
  ) async {
    return await repository.getReportHistory(userId: params.userId);
  }
}
