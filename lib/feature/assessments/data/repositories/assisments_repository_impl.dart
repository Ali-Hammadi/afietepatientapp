import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/assessments/data/datasources/assisments_remote_datasource.dart';
import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assessments/domain/repositories/assisments_repository.dart';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AssessmentsRepositoryImpl implements AssessmentsRepository {
  final AssessmentsRemoteDataSource remoteDataSource;

  const AssessmentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AssessmentsEntity>>>
      getAssessmentsQuestions() async {
    try {
      final questions = await remoteDataSource.getAssessmentsQuestions();
      return Right(questions);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioError(error));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, AssessmentsEntity>> submitAssessments({
    required List<AssessmentsEntity> answers,
  }) async {
    try {
      final result = await remoteDataSource.submitAssessments(answers: answers);
      return Right(result);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioError(error));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AssessmentScoreEntry>>>
      getAssessmentScores() async {
    try {
      final scores = await remoteDataSource.getAssessmentScores();
      return Right(scores);
    } on DioException catch (error) {
      return Left(ServerFailure.fromDioError(error));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
