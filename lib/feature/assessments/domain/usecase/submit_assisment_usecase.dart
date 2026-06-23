import 'package:afiete/core/error/failure.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assessments/domain/repositories/assisments_repository.dart';
import 'package:dartz/dartz.dart';

class SubmitAssessmentsParams {
  final List<AssessmentsEntity> answers;

  const SubmitAssessmentsParams({required this.answers});
}

class SubmitAssessmentsUseCase
    implements UseCase<AssessmentsEntity, SubmitAssessmentsParams> {
  final AssessmentsRepository repository;

  const SubmitAssessmentsUseCase(this.repository);

  @override
  Future<Either<Failure, AssessmentsEntity>> call(
      SubmitAssessmentsParams params) {
    return repository.submitAssessments(answers: params.answers);
  }
}
