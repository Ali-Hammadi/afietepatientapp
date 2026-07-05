// lib/feature/feeling/presentation/cubit/feeling_cubit.dart
import 'package:afiete/feature/feeling/domain/usecase/feeling_usecases.dart';
import 'package:afiete/feature/music_and_breathing/domain/entities/music_entity.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'feeling_state.dart';

class FeelingCubit extends Cubit<FeelingState> {
  final GetLastSelectedFeelingUseCase getLastSelectedFeelingUseCase;
  final SaveLastSelectedFeelingUseCase saveLastSelectedFeelingUseCase;
  final GetFeelingHistoryUseCase getFeelingHistoryUseCase;

  FeelingCubit(
    this.getLastSelectedFeelingUseCase,
    this.saveLastSelectedFeelingUseCase,
    this.getFeelingHistoryUseCase,
  ) : super(FeelingInitial());

  Future<void> loadFeelingHub() async {
    emit(FeelingLoading());

    final result = await getLastSelectedFeelingUseCase();

    result.fold(
      (failure) {
        emit(const FeelingLoaded(
          selectedFeeling: FeelingType.neutral,
          hasLockedFeeling: false,
        ));
      },
      (feeling) {
        emit(FeelingLoaded(
          selectedFeeling: feeling ?? FeelingType.neutral,
          hasLockedFeeling: feeling != null,
        ));
      },
    );
  }

  Future<void> selectFeeling(FeelingType feeling) async {
    final currentState = state;

    if (currentState is FeelingLoaded && currentState.hasLockedFeeling) {
      return;
    }

    if (currentState is FeelingError && currentState.hasLockedFeeling) {
      return;
    }

    emit(FeelingLoading());

    try {
      await saveLastSelectedFeelingUseCase(feeling);

      emit(FeelingLoaded(
        selectedFeeling: feeling,
        hasLockedFeeling: true,
      ));
    } catch (e) {
      emit(FeelingError(
        message: e.toString(),
        selectedFeeling: feeling,
        hasLockedFeeling: true,
      ));
    }
  }

  Future<void> resetFeeling() async {
    emit(FeelingLoading());
    try {
      await saveLastSelectedFeelingUseCase(FeelingType.neutral);
      emit(const FeelingLoaded(
        selectedFeeling: FeelingType.neutral,
        hasLockedFeeling: false,
      ));
    } catch (e) {
      emit(FeelingError(
        message: e.toString(),
        selectedFeeling: FeelingType.neutral,
        hasLockedFeeling: false,
      ));
    }
  }

  Future<void> getFeelingHistory() async {
    final result = await getFeelingHistoryUseCase();
    result.fold(
      (failure) => emit(FeelingError(
        message: failure.errorMessage,
        hasLockedFeeling: false,
      )),
      (_) {},
    );
  }
}
