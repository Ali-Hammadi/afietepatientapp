// lib/feature/music_and_breathing/domain/usecase/get_recommended_music_usecase.dart
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

// ✅ Use Cases للـ MusicCubit (تستخدم RelaxRepository)
class GetMusicLastSelectedFeelingUseCase {
  final RelaxRepository repository;
  GetMusicLastSelectedFeelingUseCase(this.repository);

  Future<Either<Failure, FeelingType>> call() =>
      repository.getLastSelectedFeeling();
}

class SaveMusicLastSelectedFeelingUseCase {
  final RelaxRepository repository;
  SaveMusicLastSelectedFeelingUseCase(this.repository);

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
