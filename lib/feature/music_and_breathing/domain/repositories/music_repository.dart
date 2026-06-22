import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/breathing_exercise_entity.dart';
import '../entities/music_entity.dart';
import '../usecase/get_recommended_music_usecase.dart';

abstract class RelaxRepository {
  Future<Either<Failure, FeelingType>> getLastSelectedFeeling();
  Future<Either<Failure, FeelingType>> saveLastSelectedFeeling(
      FeelingType feeling);
  Future<Either<Failure, List<MusicEntity>>> getRecommendedTracks(
      RecommendedMusicParams params);
  Future<Either<Failure, List<BreathingExerciseEntity>>>
      getBreathingExercises();
}
