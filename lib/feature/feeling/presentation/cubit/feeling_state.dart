// lib/feature/feeling/presentation/cubit/feeling_state.dart
part of 'feeling_cubit.dart';

abstract class FeelingState extends Equatable {
  const FeelingState();
}

class FeelingInitial extends FeelingState {
  @override
  List<Object?> get props => [];
}

class FeelingLoading extends FeelingState {
  @override
  List<Object?> get props => [];
}

class FeelingLoaded extends FeelingState {
  final FeelingType selectedFeeling;
  final bool hasLockedFeeling;

  const FeelingLoaded({
    required this.selectedFeeling,
    this.hasLockedFeeling = false,
  });

  FeelingLoaded copyWith({
    FeelingType? selectedFeeling,
    bool? hasLockedFeeling,
  }) {
    return FeelingLoaded(
      selectedFeeling: selectedFeeling ?? this.selectedFeeling,
      hasLockedFeeling: hasLockedFeeling ?? this.hasLockedFeeling,
    );
  }

  @override
  List<Object?> get props => [selectedFeeling, hasLockedFeeling];
}

class FeelingError extends FeelingState {
  final String message;
  final FeelingType? selectedFeeling;
  final bool hasLockedFeeling;

  const FeelingError({
    required this.message,
    this.selectedFeeling,
    this.hasLockedFeeling = false,
  });

  @override
  List<Object?> get props => [message, selectedFeeling, hasLockedFeeling];
}
