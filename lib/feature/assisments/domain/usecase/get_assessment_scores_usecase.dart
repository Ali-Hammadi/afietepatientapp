import 'package:afiete/core/error/failure.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assisments/domain/repositories/assisments_repository.dart';
import 'package:dartz/dartz.dart';

class GetAssessmentScoresUseCase
    implements UseCase<List<AssessmentScoreEntry>, NoParams> {
  final AssismentsRepository repository;

  GetAssessmentScoresUseCase(this.repository);

  @override
  Future<Either<Failure, List<AssessmentScoreEntry>>> call(
    NoParams params,
  ) async {
    return repository.getAssessmentScores();
  }
}
