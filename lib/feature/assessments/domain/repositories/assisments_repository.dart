import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AssessmentsRepository {
  Future<Either<Failure, List<AssessmentsEntity>>> getAssessmentsQuestions();

  Future<Either<Failure, AssessmentsEntity>> submitAssessments({
    required List<AssessmentsEntity> answers,
  });

  Future<Either<Failure, List<AssessmentScoreEntry>>> getAssessmentScores();
}
