import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AssismentsRepository {
  Future<Either<Failure, List<AssismentEntity>>> getAssismentQuestions();

  Future<Either<Failure, AssismentEntity>> submitAssisment({
    required List<AssismentEntity> answers,
  });

  Future<Either<Failure, List<AssessmentScoreEntry>>> getAssessmentScores();
}
