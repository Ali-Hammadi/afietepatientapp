import 'package:equatable/equatable.dart';

enum AssismentEntityType { question, answer, result }

class AssismentOptionEntity extends Equatable {
  final int id;
  final String text;
  final int score;

  const AssismentOptionEntity({
    required this.id,
    required this.text,
    required this.score,
  });

  @override
  List<Object?> get props => [id, text, score];
}

class AssismentEntity extends Equatable {
  final AssismentEntityType type;
  final int id;
  final String questionText;
  final List<AssismentOptionEntity> options;
  final int questionId;
  final int selectedOptionId;
  final int resultId;
  final int score;
  final String severity;
  final String summary;
  final List<String> recommendedDoctorIds;
  final List<String> recommendedSpecialties;

  const AssismentEntity._({
    required this.type,
    this.id = 0,
    this.questionText = '',
    this.options = const <AssismentOptionEntity>[],
    this.questionId = 0,
    this.selectedOptionId = 0,
    this.resultId = 0,
    this.score = 0,
    this.severity = '',
    this.summary = '',
    this.recommendedDoctorIds = const [],
    this.recommendedSpecialties = const [],
  });

  const AssismentEntity.question({
    required int id,
    required String questionText,
    required List<AssismentOptionEntity> options,
  }) : this._(
         type: AssismentEntityType.question,
         id: id,
         questionText: questionText,
         options: options,
       );

  const AssismentEntity.answer({
    required int questionId,
    required int selectedOptionId,
  }) : this._(
         type: AssismentEntityType.answer,
         questionId: questionId,
         selectedOptionId: selectedOptionId,
       );

  const AssismentEntity.result({
    required int resultId,
    required int score,
    required String severity,
    required String summary,
    required List<String> recommendedDoctorIds,
    required List<String> recommendedSpecialties,
  }) : this._(
         type: AssismentEntityType.result,
         resultId: resultId,
         score: score,
         severity: severity,
         summary: summary,
         recommendedDoctorIds: recommendedDoctorIds,
         recommendedSpecialties: recommendedSpecialties,
       );

  @override
  List<Object?> get props => [
    type,
    id,
    questionText,
    options,
    questionId,
    selectedOptionId,
    resultId,
    score,
    severity,
    summary,
    recommendedDoctorIds,
    recommendedSpecialties,
  ];
}
