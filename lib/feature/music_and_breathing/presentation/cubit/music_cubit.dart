import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/breathing_exercise_entity.dart';
import '../../domain/entities/music_entity.dart';
import '../../domain/usecase/get_recommended_music_usecase.dart';

part 'music_state.dart';

class MusicCubit extends Cubit<MusicState> {
  final GetRecommendedMusicUseCase getRecommendedMusicUseCase;
  final GetBreathingExercisesUseCase getBreathingExercisesUseCase;
  final GetLastSelectedFeelingUseCase getLastSelectedFeelingUseCase;
  final SaveLastSelectedFeelingUseCase saveLastSelectedFeelingUseCase;

  MusicCubit(
    this.getRecommendedMusicUseCase,
    this.getBreathingExercisesUseCase,
    this.getLastSelectedFeelingUseCase,
    this.saveLastSelectedFeelingUseCase,
  ) : super(MusicInitial());

  Future<void> loadHub() async {
    emit(MusicLoading());

    final lastFeelingResult = await getLastSelectedFeelingUseCase();
    final breathingResult = await getBreathingExercisesUseCase();

    final resolvedFeeling = lastFeelingResult.fold(
      (_) => FeelingType.neutral,
      (feeling) => feeling,
    );

    final tracksResult = await getRecommendedMusicUseCase(
      RecommendedMusicParams(
        feeling: resolvedFeeling,
        limit: 10,
      ),
    );

    final tracks = tracksResult.fold((_) => <MusicEntity>[], (items) => items);
    final breathingExercises = breathingResult.fold(
      (_) => <BreathingExerciseEntity>[],
      (items) => items,
    );

    emit(
      MusicLoaded(
        selectedFeeling: resolvedFeeling,
        tracks: tracks,
        breathingExercises: breathingExercises,
        activeTrack: tracks.isNotEmpty ? tracks.first : null,
        activeBreathingExercise:
            breathingExercises.isNotEmpty ? breathingExercises.first : null,
        hasSavedFeeling: lastFeelingResult.isRight(),
      ),
    );
  }

  Future<void> selectFeeling(FeelingType feeling) async {
    final currentState = state;
    if (currentState is MusicLoaded) {
      emit(currentState.copyWith(selectedFeeling: feeling));
    } else {
      emit(MusicLoading());
    }

    await saveLastSelectedFeelingUseCase(feeling);

    final tracksResult = await getRecommendedMusicUseCase(
      RecommendedMusicParams(
        feeling: feeling,
        limit: 10,
      ),
    );
    final breathingResult = await getBreathingExercisesUseCase();

    final tracks = tracksResult.fold((_) => <MusicEntity>[], (items) => items);
    final breathingExercises = breathingResult.fold(
      (_) => <BreathingExerciseEntity>[],
      (items) => items,
    );

    emit(
      MusicLoaded(
        selectedFeeling: feeling,
        tracks: tracks,
        breathingExercises: breathingExercises,
        activeTrack: tracks.isNotEmpty ? tracks.first : null,
        activeBreathingExercise:
            breathingExercises.isNotEmpty ? breathingExercises.first : null,
        hasSavedFeeling: true,
      ),
    );
  }

  void selectTrack(MusicEntity track) {
    final currentState = state;
    if (currentState is MusicLoaded) {
      emit(currentState.copyWith(activeTrack: track));
    }
  }

  void selectBreathingExercise(BreathingExerciseEntity exercise) {
    final currentState = state;
    if (currentState is MusicLoaded) {
      emit(currentState.copyWith(activeBreathingExercise: exercise));
    }
  }
}
