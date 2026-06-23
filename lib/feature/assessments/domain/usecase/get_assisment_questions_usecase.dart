import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assessments/domain/repositories/assisments_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:afiete/core/error/failure.dart';

class GetAssessmentsQuestionsUseCase
    implements UseCase<List<AssessmentsEntity>, NoParams> {
  final AssessmentsRepository repository;

  const GetAssessmentsQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AssessmentsEntity>>> call(NoParams params) {
    return repository.getAssessmentsQuestions();
  }
}
