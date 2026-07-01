import 'package:afiete/core/error/failure.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/sessions/domain/entities/review_entity.dart';
import 'package:afiete/feature/sessions/domain/repositories/sessions_repository.dart';
import 'package:dartz/dartz.dart';

class AddReviewParams {
  final dynamic appointmentId;
  final int rating;
  final String? comment;

  const AddReviewParams({
    required this.appointmentId,
    required this.rating,
    this.comment,
  });
}

class AddReviewUseCase implements UseCase<ReviewEntity, AddReviewParams> {
  final SessionsRepository repository;

  const AddReviewUseCase(this.repository);

  @override
  Future<Either<Failure, ReviewEntity>> call(AddReviewParams params) {
    return repository.addReview(
      appointmentId: params.appointmentId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}
