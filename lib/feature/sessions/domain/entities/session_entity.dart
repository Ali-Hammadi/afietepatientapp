import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  final String id;
  final String username;
  final String doctorName;
  final String doctorSpecialization;
  final String? doctorImageUrl;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String sessionType;
  final String status;
  final bool isUpcoming;

  const SessionEntity({
    required this.id,
    required this.username,
    required this.doctorName,
    required this.doctorSpecialization,
    this.doctorImageUrl,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.sessionType,
    required this.status,
    required this.isUpcoming,
  });

  DateTime get endAt => scheduledAt.add(Duration(minutes: durationMinutes));

  String get timeRange {
    final localStart = scheduledAt.toLocal();
    final localEnd = endAt.toLocal();
    final start =
        '${localStart.hour}:${localStart.minute.toString().padLeft(2, '0')}';
    final end =
        '${localEnd.hour}:${localEnd.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  @override
  List<Object?> get props => [
        id,
        username,
        doctorName,
        doctorSpecialization,
        doctorImageUrl,
        scheduledAt,
        durationMinutes,
        sessionType,
        status,
        isUpcoming,
      ];
}
