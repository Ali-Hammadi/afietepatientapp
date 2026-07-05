// lib/feature/courses/domain/entities/course_entity.dart
import 'package:equatable/equatable.dart';

enum CourseStatus {
  active,
  pendingClose,
  completed;

  static CourseStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return CourseStatus.active;
      case 'pending_close':
      case 'pendingclose':
        return CourseStatus.pendingClose;
      case 'completed':
        return CourseStatus.completed;
      default:
        return CourseStatus.active;
    }
  }

  String get displayName {
    switch (this) {
      case CourseStatus.active:
        return 'Active';
      case CourseStatus.pendingClose:
        return 'Pending Close';
      case CourseStatus.completed:
        return 'Completed';
    }
  }
}

class CourseEntity extends Equatable {
  final int id;
  final String patientUsername;
  final String doctorUsername;
  final CourseStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int sessionsCount;
  final bool continueRequested;

  const CourseEntity({
    required this.id,
    required this.patientUsername,
    required this.doctorUsername,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.sessionsCount = 0,
    this.continueRequested = false,
  });

  bool get isActive => status == CourseStatus.active;
  bool get isPendingClose => status == CourseStatus.pendingClose;
  bool get isCompleted => status == CourseStatus.completed;

  @override
  List<Object?> get props => [
        id,
        patientUsername,
        doctorUsername,
        status,
        startedAt,
        endedAt,
        sessionsCount,
        continueRequested,
      ];
}
