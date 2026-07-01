import 'package:afiete/feature/sessions/domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.username,
    required super.doctorName,
    required super.doctorSpecialization,
    super.doctorImageUrl,
    required super.scheduledAt,
    required super.durationMinutes,
    required super.sessionType,
    required super.status,
    required super.isUpcoming,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final scheduledAtRaw = _readString(json, const ['scheduledAt', 'date']);
    final scheduledAt = scheduledAtRaw != null
        ? DateTime.parse(scheduledAtRaw)
        : DateTime.now();

    final username = _readString(
          json,
          const ['doctorId', 'doctor_username', 'doctorUsername'],
        ) ??
        _readNestedString(json['doctor'], const ['username']) ??
        '';

    final doctorName = _readString(json, const ['doctorName']) ??
        _readNestedDoctorName(json['doctor']) ??
        username;

    final doctorSpecialization = _readString(
          json,
          const ['doctorSpecialization', 'specialization'],
        ) ??
        _readNestedString(json['doctor'], const ['specialization']) ??
        'General';

    final durationMinutes = _readInt(
          json,
          const ['durationMinutes', 'duration_minutes', 'duration'],
        ) ??
        30;

    return SessionModel(
      id: _readString(json, const ['id', 'sessionId']) ?? '',
      username: username,
      doctorName: doctorName,
      doctorSpecialization: doctorSpecialization,
      doctorImageUrl: _readString(json, const ['doctorImageUrl', 'photo']),
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      sessionType: _readString(json, const ['sessionType', 'type']) ?? 'video',
      status: _readString(json, const ['status']) ?? 'pending',
      isUpcoming: scheduledAt.isAfter(DateTime.now()),
    );
  }

  factory SessionModel.fromEntity(SessionEntity entity) {
    return SessionModel(
      id: entity.id,
      username: entity.username,
      doctorName: entity.doctorName,
      doctorSpecialization: entity.doctorSpecialization,
      doctorImageUrl: entity.doctorImageUrl,
      scheduledAt: entity.scheduledAt,
      durationMinutes: entity.durationMinutes,
      sessionType: entity.sessionType,
      status: entity.status,
      isUpcoming: entity.isUpcoming,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': username,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'doctorImageUrl': doctorImageUrl,
      'scheduledAt': scheduledAt.toIso8601String(),
      'durationMinutes': durationMinutes,
      'sessionType': sessionType,
      'status': status,
    };
  }

  static String? _readString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        return value.toString();
      }
    }
    return null;
  }

  static String? _readNestedString(dynamic value, List<String> keys) {
    if (value is Map<String, dynamic>) {
      for (final key in keys) {
        final nestedValue = value[key];
        if (nestedValue != null) {
          return nestedValue.toString();
        }
      }
    }
    return null;
  }

  static String? _readNestedDoctorName(dynamic value) {
    if (value is Map<String, dynamic>) {
      final user = value['user'];
      if (user is Map<String, dynamic>) {
        final firstName = user['first_name']?.toString().trim() ?? '';
        final lastName = user['last_name']?.toString().trim() ?? '';
        final fullName = '$firstName $lastName'.trim();
        if (fullName.isNotEmpty) {
          return fullName;
        }

        final username = user['username']?.toString().trim() ?? '';
        if (username.isNotEmpty) {
          return username;
        }
      }

      final username = value['username']?.toString().trim() ?? '';
      if (username.isNotEmpty) {
        return username;
      }
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value != null) {
        final parsed = int.tryParse(value.toString());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }
}
