import 'package:equatable/equatable.dart';

enum AssessmentsEntityType { question, answer, result }

class AssessmentScoreEntry extends Equatable {
  final String name;
  final int score;
  final int raw;
  final int max;
  final String severity;

  const AssessmentScoreEntry({
    required this.name,
    required this.score,
    required this.raw,
    required this.max,
    required this.severity,
  });

  @override
  List<Object?> get props => [name, score, raw, max, severity];
}

class AssessmentsOptionEntity extends Equatable {
  final int id;
  final String text;
  final int score;

  const AssessmentsOptionEntity({
    required this.id,
    required this.text,
    required this.score,
  });

  @override
  List<Object?> get props => [id, text, score];
}

class AssessmentsEntity extends Equatable {
  final AssessmentsEntityType type;
  final int id;
  final String questionText;
  final List<AssessmentsOptionEntity> options;
  final int questionId;
  final int selectedOptionId;
  final int resultId;
  final int score;
  final String severity;
  final String summary;
  final List<String> recommendedDoctorUsrnames;
  final List<String> recommendedSpecialties;

  const AssessmentsEntity._({
    required this.type,
    this.id = 0,
    this.questionText = '',
    this.options = const <AssessmentsOptionEntity>[],
    this.questionId = 0,
    this.selectedOptionId = 0,
    this.resultId = 0,
    this.score = 0,
    this.severity = '',
    this.summary = '',
    this.recommendedDoctorUsrnames = const [],
    this.recommendedSpecialties = const [],
  });

  const AssessmentsEntity.question({
    required int id,
    required String questionText,
    required List<AssessmentsOptionEntity> options,
  }) : this._(
          type: AssessmentsEntityType.question,
          id: id,
          questionText: questionText,
          options: options,
        );

  const AssessmentsEntity.answer({
    required int questionId,
    required int selectedOptionId,
  }) : this._(
          type: AssessmentsEntityType.answer,
          questionId: questionId,
          selectedOptionId: selectedOptionId,
        );

  const AssessmentsEntity.result({
    required int resultId,
    required int score,
    required String severity,
    required String summary,
    required List<String> recommendedDoctorIds,
    required List<String> recommendedSpecialties,
  }) : this._(
          type: AssessmentsEntityType.result,
          resultId: resultId,
          score: score,
          severity: severity,
          summary: summary,
          recommendedDoctorUsrnames: recommendedDoctorIds,
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
        recommendedDoctorUsrnames,
        recommendedSpecialties,
      ];
}
