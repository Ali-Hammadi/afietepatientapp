// lib/feature/feeling/domain/usecase/feeling_usecases.dart
import 'package:afiete/feature/music_and_breathing/domain/entities/music_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/feeling_entry_entity.dart';
import '../repositories/feeling_repository.dart';

class SaveFeelingUseCase {
  final FeelingRepository repository;
  SaveFeelingUseCase(this.repository);

  Future<Either<Failure, FeelingEntryEntity>> call({
    required FeelingType feeling,
    int intensity = 3,
  }) =>
      repository.saveFeeling(feeling: feeling, intensity: intensity);
}

class GetCurrentFeelingUseCase {
  final FeelingRepository repository;
  GetCurrentFeelingUseCase(this.repository);

  Future<Either<Failure, FeelingType?>> call() =>
      repository.getCurrentFeeling();
}

class GetFeelingHistoryUseCase {
  final FeelingRepository repository;
  GetFeelingHistoryUseCase(this.repository);

  Future<Either<Failure, List<FeelingEntryEntity>>> call({int limit = 10}) =>
      repository.getFeelingHistory(limit: limit);
}

// ✅ Use Cases جديدة لـ FeelingCubit (تستخدم FeelingRepository)
class GetLastSelectedFeelingUseCase {
  final FeelingRepository repository;
  GetLastSelectedFeelingUseCase(this.repository);

  Future<Either<Failure, FeelingType?>> call() =>
      repository.getCurrentFeeling();
}

class SaveLastSelectedFeelingUseCase {
  final FeelingRepository repository;
  SaveLastSelectedFeelingUseCase(this.repository);

  Future<Either<Failure, FeelingEntryEntity>> call(FeelingType feeling) =>
      repository.saveFeeling(feeling: feeling);
}
