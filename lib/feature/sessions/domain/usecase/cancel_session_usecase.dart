import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/sessions/domain/repositories/sessions_repository.dart';
import 'package:dartz/dartz.dart';

class CancelSessionParams {
  final String sessionId;
  final String doctorId;

  const CancelSessionParams({required this.sessionId, required this.doctorId});
}

class CancelSessionUseCase implements UseCase<void, CancelSessionParams> {
  final SessionsRepository repository;

  const CancelSessionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelSessionParams params) {
    return repository.cancelSession(
      sessionId: params.sessionId,
      doctorId: params.doctorId,
    );
  }
}
