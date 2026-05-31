import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/feature/assisments/data/datasources/assisments_remote_datasource.dart';
import 'package:afietepatientapp/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:afietepatientapp/feature/assisments/domain/repositories/assisments_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AssismentsRepositoryImpl implements AssismentsRepository {
  final AssismentsRemoteDataSource remoteDataSource;

  const AssismentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AssismentEntity>>> getAssismentQuestions() async {
    try {
      final questions = await remoteDataSource.getAssismentQuestions();
      return Right(questions);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioError(error));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, AssismentEntity>> submitAssisment({
    required List<AssismentEntity> answers,
  }) async {
    try {
      final result = await remoteDataSource.submitAssisment(answers: answers);
      return Right(result);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioError(error));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
