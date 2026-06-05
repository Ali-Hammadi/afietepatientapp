import 'package:afiete/core/error/failure.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assisments/domain/repositories/assisments_repository.dart';
import 'package:dartz/dartz.dart';

class SubmitAssismentParams {
  final List<AssismentEntity> answers;

  const SubmitAssismentParams({required this.answers});
}

class SubmitAssismentUseCase
    implements UseCase<AssismentEntity, SubmitAssismentParams> {
  final AssismentsRepository repository;

  const SubmitAssismentUseCase(this.repository);

  @override
  Future<Either<Failure, AssismentEntity>> call(SubmitAssismentParams params) {
    return repository.submitAssisment(answers: params.answers);
  }
}
