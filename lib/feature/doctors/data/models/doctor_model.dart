import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:equatable/equatable.dart';

class DoctorSessionPriceModel extends Equatable {
  final int duration;
  final String type;
  final double price;

  const DoctorSessionPriceModel({
    required this.duration,
    required this.type,
    required this.price,
  });

  factory DoctorSessionPriceModel.fromJson(Map<String, dynamic> json) {
    return DoctorSessionPriceModel(
      duration: _readInt(json['duration']) ?? 0,
      type: _normalizeSessionType(_readString(json['type']) ?? ''),
      price: _readDouble(json['price']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'duration': duration,
        'type': type,
        'price': price,
      };

  DoctorSessionPrice toEntity() =>
      DoctorSessionPrice(duration: duration, type: type, price: price);

  @override
  List<Object> get props => [duration, type, price];
}

class DoctorScheduleModel extends Equatable {
  final String id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  const DoctorScheduleModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleModel(
      id: _readString(json['id']) ?? '',
      dayOfWeek: _readString(json['day_of_week'] ?? json['day']) ?? '',
      startTime: _readString(json['start_time'] ?? json['start']) ?? '',
      endTime: _readString(json['end_time'] ?? json['end']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
      };

  DoctorSchedule toEntity() => DoctorSchedule(
        id: id,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );

  @override
  List<Object> get props => [id, dayOfWeek, startTime, endTime];
}

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.doctorUsername,
    required super.name,
    required super.specialties,
    required super.bio,
    required super.imageUrl,
    required super.sessionPrices,
    required super.schedules,
    super.ratingValue,
    super.experienceYears,
    super.jobTitle,
    super.specialization,
    super.experience,
    super.rating,
    super.patients_count,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;

    final username = _readString(json['username'] ??
            json['doctor_username'] ??
            userMap?['username']) ??
        '';

    String name = _readString(json['name']) ?? '';
    if (name.isEmpty && userMap != null) {
      final firstName = _readString(userMap['first_name']) ?? '';
      final lastName = _readString(userMap['last_name']) ?? '';
      name = '$firstName $lastName'.trim();
    }
    if (name.isEmpty) {
      name = username;
    }

    final patientsCountStr =
        _readString(json['patients_count'] ?? json['patients']) ?? '0';

    final rawPrices = json['session_prices'] ?? json['prices'] ?? const [];
    final prices = rawPrices is List
        ? rawPrices
            .map((e) =>
                DoctorSessionPriceModel.fromJson(e as Map<String, dynamic>)
                    .toEntity())
            .toList()
        : const <DoctorSessionPrice>[];

    final rawSchedules = json['schedules'] ?? json['schedule'] ?? const [];
    final schedules = rawSchedules is List
        ? rawSchedules
            .map((e) => DoctorScheduleModel.fromJson(e as Map<String, dynamic>)
                .toEntity())
            .toList()
        : const <DoctorSchedule>[];

    final ratingVal = _readDouble(json['average_rating']) ?? 0.0;
    final expYears = _readInt(json['experience']) ?? 0;

    final jobTitleMap = json['job_title'] is Map<String, dynamic>
        ? json['job_title'] as Map<String, dynamic>
        : null;
    final title = _readString(jobTitleMap?['title']) ?? '';

    final rawSpecialties = json['specialties'] as List?;
    final List<String> specialtiesList = [];
    String firstSpecialtyId = '';

    if (rawSpecialties != null) {
      for (final item in rawSpecialties) {
        if (item is Map<String, dynamic>) {
          final sName = _readString(item['name']);
          if (sName != null && sName.isNotEmpty) {
            specialtiesList.add(sName);
          }
          if (firstSpecialtyId.isEmpty) {
            final sId = item['id'];
            if (sId != null) {
              firstSpecialtyId = sId.toString();
            }
          }
        } else {
          final sStr = _readString(item);
          if (sStr != null && sStr.isNotEmpty) {
            specialtiesList.add(sStr);
          }
        }
      }
    }

    return DoctorModel(
        doctorUsername: username,
        name: name,
        specialties: specialtiesList,
        bio: _readString(json['bio'] ?? json['description']) ?? '',
        imageUrl: _readString(json['image_path'] ?? json['photo']) ?? '',
        sessionPrices: prices,
        schedules: schedules,
        ratingValue: ratingVal,
        experienceYears: expYears,
        jobTitle: title,
        specialization: firstSpecialtyId,
        experience: '$expYears years',
        rating: ratingVal.toStringAsFixed(1),
        patients_count: patientsCountStr);
  }

  Map<String, dynamic> toJson() {
    return {
      'username': doctorUsername,
      'name': name,
      'specialties': specialties,
      'bio': bio,
      'profile_picture': imageUrl,
      'average_rating': ratingValue,
      'patients_count': patients_count,
      'experience': experienceYears,
      'session_prices': sessionPrices
          .map((e) => {
                'duration': e.duration,
                'type': e.type,
                'price': e.price,
              })
          .toList(),
      'schedules': schedules
          .map((e) => {
                'day_of_week': e.dayOfWeek,
                'start_time': e.startTime,
                'end_time': e.endTime,
              })
          .toList(),
    };
  }
}

// دالات المساعدة (Helpers)
String _normalizeSessionType(String value) {
  switch (value.trim().toLowerCase()) {
    case 'video':
      return 'video_call';
    case 'voice':
      return 'voice_call';
    case 'chat':
    case 'text':
      return 'text_chat';
    default:
      return value.trim();
  }
}

String? _readString(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value != null) return int.tryParse(value.toString());
  return null;
}

double? _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value != null) return double.tryParse(value.toString());
  return null;
}
