import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/settings/domin/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SubmitReportIssueParams {
  final String userId;
  final String reason;
  final String details;

  const SubmitReportIssueParams({
    required this.userId,
    required this.reason,
    required this.details,
  });
}

class SubmitReportIssueUseCase
    implements UseCase<String, SubmitReportIssueParams> {
  final SettingsRepository repository;

  const SubmitReportIssueUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SubmitReportIssueParams params) {
    return repository.submitReportIssue(
      userId: params.userId,
      reason: params.reason,
      details: params.details,
    );
  }
}
