import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assisments/domain/repositories/assisments_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:afiete/core/error/failure.dart';

class GetAssismentQuestionsUseCase
    implements UseCase<List<AssismentEntity>, NoParams> {
  final AssismentsRepository repository;

  const GetAssismentQuestionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AssismentEntity>>> call(NoParams params) {
    return repository.getAssismentQuestions();
  }
}
