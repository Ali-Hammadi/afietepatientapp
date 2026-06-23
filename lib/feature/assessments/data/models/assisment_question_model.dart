import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';

abstract class AssessmentsModel {
  static List<AssessmentScoreEntry> fromScoresJson(Map<String, dynamic> json) {
    return json.entries.map((entry) {
      final data = entry.value is Map<String, dynamic>
          ? entry.value as Map<String, dynamic>
          : <String, dynamic>{};
      return AssessmentScoreEntry(
        name: entry.key,
        score: (data['score'] as num?)?.toInt() ?? 0,
        raw: (data['raw'] as num?)?.toInt() ?? 0,
        max: (data['max'] as num?)?.toInt() ?? 0,
        severity: (data['severity'] ?? '').toString(),
      );
    }).toList();
  }

  static List<AssessmentsOptionEntity> _parseOptions(dynamic value) {
    final rawOptions = value is List ? value : const <dynamic>[];

    return rawOptions
        .whereType<Map<String, dynamic>>()
        .map(
          (option) => AssessmentsOptionEntity(
            id: (option['id'] as num?)?.toInt() ?? 0,
            text: (option['text'] ?? '').toString(),
            score: (option['score'] as num?)?.toInt() ?? 0,
          ),
        )
        .where((option) => option.id != 0 || option.text.isNotEmpty)
        .toList();
  }

  static AssessmentsEntity fromQuestionJson(Map<String, dynamic> json) {
    final options = _parseOptions(json['options']);

    return AssessmentsEntity.question(
      id: (json['id'] as num?)?.toInt() ?? 0,
      questionText: (json['text'] ?? json['questionText'] ?? '').toString(),
      options: options,
    );
  }

  static AssessmentsEntity fromResultJson(Map<String, dynamic> json) {
    final recommendation = json['recommendation'] is Map<String, dynamic>
        ? json['recommendation'] as Map<String, dynamic>
        : json['recommendations'] is Map<String, dynamic>
            ? json['recommendations'] as Map<String, dynamic>
            : const <String, dynamic>{};

    final doctorIdsRaw = (recommendation['doctorIds'] ??
        json['recommendedDoctorIds'] ??
        const []) as List<dynamic>;
    final specialtiesRaw = (recommendation['specialties'] ??
        json['recommendedSpecialties'] ??
        const []) as List<dynamic>;

    return AssessmentsEntity.result(
      resultId: (json['resultId'] as num?)?.toInt() ??
          (json['id'] as num?)?.toInt() ??
          0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      severity: (json['severity'] ?? json['level'] ?? 'unknown').toString(),
      summary: (json['summary'] ?? json['message'] ?? '').toString(),
      recommendedDoctorIds:
          doctorIdsRaw.map((doctorId) => doctorId.toString()).toList(),
      recommendedSpecialties:
          specialtiesRaw.map((specialty) => specialty.toString()).toList(),
    );
  }
}
