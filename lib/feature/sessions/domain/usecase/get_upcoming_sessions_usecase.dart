import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/sessions/domain/entities/session_entity.dart';
import 'package:afietepatientapp/feature/sessions/domain/repositories/sessions_repository.dart';
import 'package:dartz/dartz.dart';

class GetUpcomingSessionsUseCase
    implements UseCase<List<SessionEntity>, NoParams> {
  final SessionsRepository repository;

  const GetUpcomingSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<SessionEntity>>> call(NoParams params) {
    return repository.getUpcomingSessions();
  }
}
