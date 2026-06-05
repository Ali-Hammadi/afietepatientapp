import 'package:dartz/dartz.dart';
import 'package:afiete/core/error/failure.dart';

abstract class UseCase<DataType, Params> {
  Future<Either<Failure, DataType>> call(Params params);
}

class NoParams {}
