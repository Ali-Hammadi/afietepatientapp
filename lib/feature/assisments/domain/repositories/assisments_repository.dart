import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AssismentsRepository {
  Future<Either<Failure, List<AssismentEntity>>> getAssismentQuestions();

  Future<Either<Failure, AssismentEntity>> submitAssisment({
    required List<AssismentEntity> answers,
  });
}
