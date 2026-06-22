import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/breathing_exercise_entity.dart';
import '../../domain/entities/music_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../../domain/usecase/get_recommended_music_usecase.dart';
import '../datasources/relax_remote_data_source.dart';

class RelaxRepositoryImpl implements RelaxRepository {
  final RelaxRemoteDataSource remoteDataSource;

  RelaxRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, FeelingType>> getLastSelectedFeeling() async {
    try {
      final result = await remoteDataSource.getLastSelectedFeeling();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FeelingType>> saveLastSelectedFeeling(
      FeelingType feeling) async {
    try {
      final result = await remoteDataSource.saveLastSelectedFeeling(feeling);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MusicEntity>>> getRecommendedTracks(
      RecommendedMusicParams params) async {
    try {
      final result = await remoteDataSource.getRecommendedTracks(params);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BreathingExerciseEntity>>>
      getBreathingExercises() async {
    try {
      final result = await remoteDataSource.getBreathingExercises();
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
