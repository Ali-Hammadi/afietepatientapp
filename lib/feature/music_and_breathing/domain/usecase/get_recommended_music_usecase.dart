import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/breathing_exercise_entity.dart';
import '../entities/music_entity.dart';
import '../repositories/music_repository.dart';

class RecommendedMusicParams {
  final FeelingType feeling;
  final int limit;
  final String? excludeTrackId;

  RecommendedMusicParams({
    required this.feeling,
    required this.limit,
    this.excludeTrackId,
  });
}

class GetLastSelectedFeelingUseCase {
  final RelaxRepository repository;
  GetLastSelectedFeelingUseCase(this.repository);

  Future<Either<Failure, FeelingType>> call() =>
      repository.getLastSelectedFeeling();
}

class SaveLastSelectedFeelingUseCase {
  final RelaxRepository repository;
  SaveLastSelectedFeelingUseCase(this.repository);

  Future<Either<Failure, void>> call(FeelingType feeling) =>
      repository.saveLastSelectedFeeling(feeling);
}

class GetRecommendedMusicUseCase {
  final RelaxRepository repository;
  GetRecommendedMusicUseCase(this.repository);

  Future<Either<Failure, List<MusicEntity>>> call(
          RecommendedMusicParams params) =>
      repository.getRecommendedTracks(params);
}

class GetBreathingExercisesUseCase {
  final RelaxRepository repository;
  GetBreathingExercisesUseCase(this.repository);

  Future<Either<Failure, List<BreathingExerciseEntity>>> call() =>
      repository.getBreathingExercises();
}
