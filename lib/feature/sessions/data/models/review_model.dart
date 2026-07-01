import 'package:afiete/feature/sessions/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.sessionId,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['reviewId'] ?? json['pk'] ?? '';
    final rawSessionId =
        json['sessionId'] ?? json['session_id'] ?? json['appointmentId'] ?? '';
    final rawRating = json['rating'] ?? json['score'] ?? 0;
    final rawComment = json['comment'] ?? json['review'] ?? '';
    final rawCreatedAt = json['createdAt'] ??
        json['created_at'] ??
        DateTime.now().toUtc().toIso8601String();

    return ReviewModel(
      id: rawId.toString(),
      sessionId: rawSessionId.toString(),
      rating: rawRating is int
          ? rawRating
          : int.tryParse(rawRating.toString()) ?? 0,
      comment: rawComment.toString(),
      createdAt:
          DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now().toUtc(),
    );
  }

  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      sessionId: entity.sessionId,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
