// lib/feature/courses/data/models/course_model.dart
import 'package:afiete/feature/cources/domain/entities/cources_entities.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.patientUsername,
    required super.doctorUsername,
    required super.status,
    super.startedAt,
    super.endedAt,
    super.sessionsCount,
    super.continueRequested,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      patientUsername: json['patient_username'] as String? ?? '',
      doctorUsername: json['doctor_username'] as String? ?? '',
      status: CourseStatus.fromString(json['status'] as String? ?? 'active'),
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'] as String)
          : null,
      sessionsCount: json['sessions_count'] as int? ?? 0,
      continueRequested: json['continue_requested'] as bool? ?? false,
    );
  }

  factory CourseModel.fromEntity(CourseEntity entity) {
    return CourseModel(
      id: entity.id,
      patientUsername: entity.patientUsername,
      doctorUsername: entity.doctorUsername,
      status: entity.status,
      startedAt: entity.startedAt,
      endedAt: entity.endedAt,
      sessionsCount: entity.sessionsCount,
      continueRequested: entity.continueRequested,
    );
  }
}
