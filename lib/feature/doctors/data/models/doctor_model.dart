import 'package:equatable/equatable.dart';
import 'package:afietepatientapp/feature/appoinments/domain/values/consultation_fee.dart';
import 'package:afietepatientapp/feature/doctors/domain/entites/doctor_entity.dart';

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
    'price': price.toString(),
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
      dayOfWeek: _readString(json['day_of_week']) ?? '',
      startTime: _readString(json['start_time']) ?? '',
      endTime: _readString(json['end_time']) ?? '',
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

class DoctorModel extends Equatable {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final String rating;
  final String imageUrl;
  final String description;
  final bool isOnline;
  final double ratingValue;
  final DateTime createdAt;
  final List<DateTime> availableTimes;
  final List<int> availableDurations;
  final List<String> availableSessionTypes;
  final ConsultationFee consultationFee;
  final String? email;
  final String? username;
  final String? gender;
  final DateTime? birthDate;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? age;
  final String? jobTitle;
  final List<String> specialties;
  final int? experienceYears;
  final String? bio;
  final List<DoctorSessionPriceModel> sessionPrices;
  final List<DoctorScheduleModel> schedules;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.imageUrl,
    required this.description,
    required this.isOnline,
    required this.ratingValue,
    required this.createdAt,
    required this.availableTimes,
    required this.availableDurations,
    required this.availableSessionTypes,
    required this.consultationFee,
    required this.specialties,
    required this.sessionPrices,
    required this.schedules,
    this.email,
    this.username,
    this.gender,
    this.birthDate,
    this.phone,
    this.firstName,
    this.lastName,
    this.age,
    this.jobTitle,
    this.experienceYears,
    this.bio,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final jobTitle = json['job_title'] as Map<String, dynamic>? ?? const {};
    final specialties = _parseSpecialties(json['specialties']);
    final sessionPrices = _parseSessionPrices(json['session_prices']);
    final schedules = _parseSchedules(
      json['schedules'] ?? json['schedule'] ?? json['sessions'],
    );
    final consultationFee = json['consultationFee'] as Map<String, dynamic>?;
    final legacyAvailableTimes = _parseDateTimes(json['availableTimes']);
    final legacyAvailableDurations = _parseInts(json['availableDurations']);
    final legacySessionTypes = _parseSessionTypes(
      json['availableSessionTypes'],
    );
    final normalizedSessionPrices = sessionPrices;
    final normalizedSchedules = schedules;
    final firstName = _readString(user['first_name'] ?? json['first_name']);
    final lastName = _readString(user['last_name'] ?? json['last_name']);
    final username = _readString(user['username'] ?? json['username']);
    final email = _readString(user['email'] ?? json['email']);
    final specialization = specialties.isNotEmpty
        ? specialties.first
        : _readString(jobTitle['title']) ??
              _readString(json['specialization']) ??
              '';
    final experienceYears = _readInt(json['experience']);
    final experience =
        _readString(json['experience']) ??
        (experienceYears != null ? '$experienceYears years' : '');
    final bio = _readString(json['bio']) ?? _readString(json['description']);
    final name = _composeName(firstName, lastName, username, json);
    final availableTimes = legacyAvailableTimes.isNotEmpty
        ? legacyAvailableTimes
        : _deriveAvailableTimes(normalizedSchedules);
    final availableDurations = legacyAvailableDurations.isNotEmpty
        ? legacyAvailableDurations
        : _deriveAvailableDurations(
            normalizedSessionPrices,
            normalizedSchedules,
          );
    final availableSessionTypes = legacySessionTypes.isNotEmpty
        ? legacySessionTypes
        : normalizedSessionPrices.map((price) => price.type).toList();
    final parsedConsultationFee = _consultationFeeFromSessionPrices(
      normalizedSessionPrices,
    );

    return DoctorModel(
      id: _readString(json['id']) ?? username ?? email ?? '',
      name: name,
      specialization: specialization,
      experience: experience,
      rating:
          _readString(json['rating']) ??
          _formatRating(_readDouble(json['ratingValue'])),
      imageUrl:
          _readString(json['imageUrl']) ??
          _readString(json['image_url']) ??
          _readString(json['photo']) ??
          '',
      description: bio ?? '',
      isOnline:
          _readBool(json['isOnline']) ?? _readBool(json['is_online']) ?? false,
      ratingValue:
          _readDouble(json['ratingValue']) ??
          _readDouble(json['rating']) ??
          0.0,
      createdAt:
          _readDateTime(json['createdAt']) ??
          _readDateTime(json['created_at']) ??
          DateTime.now(),
      availableTimes: availableTimes,
      availableDurations: availableDurations.isNotEmpty
          ? availableDurations
          : const [],
      availableSessionTypes: availableSessionTypes.isNotEmpty
          ? availableSessionTypes
          : const [],
      consultationFee:
          parsedConsultationFee ??
          (consultationFee != null
              ? ConsultationFee(
                  textChat:
                      _readDouble(
                        consultationFee['textChat'] ??
                            consultationFee['text_chat'],
                      ) ??
                      10,
                  videoCall:
                      _readDouble(
                        consultationFee['videoCall'] ??
                            consultationFee['video_call'],
                      ) ??
                      20,
                  voiceCall:
                      _readDouble(
                        consultationFee['voiceCall'] ??
                            consultationFee['voice_call'],
                      ) ??
                      15,
                )
              : const ConsultationFee(
                  textChat: 10,
                  videoCall: 20,
                  voiceCall: 15,
                )),
      email: email,
      username: username,
      gender: _readString(user['gender'] ?? json['gender']),
      birthDate: _readDateTime(user['birth_date'] ?? json['birth_date']),
      phone: _readString(user['phone'] ?? json['phone']),
      firstName: firstName,
      lastName: lastName,
      age: _readString(user['age'] ?? json['age']),
      jobTitle:
          _readString(jobTitle['title']) ?? _readString(json['job_title']),
      specialties: specialties,
      experienceYears: experienceYears,
      bio: bio,
      sessionPrices: normalizedSessionPrices,
      schedules: normalizedSchedules,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': {
      'email': email,
      'username': username,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
    },
    'job_title': {'title': jobTitle ?? specialization},
    'specialties': specialties.map((specialty) => {'name': specialty}).toList(),
    'experience': experienceYears ?? 0,
    'bio': bio ?? description,
    'session_prices': sessionPrices.map((price) => price.toJson()).toList(),
    'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
    'name': name,
    'specialization': specialization,
    'experience_label': experience,
    'rating': rating,
    'imageUrl': imageUrl,
    'description': description,
    'isOnline': isOnline,
    'ratingValue': ratingValue,
    'createdAt': createdAt.toIso8601String(),
    'availableTimes': availableTimes.map((e) => e.toIso8601String()).toList(),
    'availableDurations': availableDurations,
    'availableSessionTypes': availableSessionTypes,
    'consultationFee': {
      'textChat': consultationFee.textChat,
      'videoCall': consultationFee.videoCall,
      'voiceCall': consultationFee.voiceCall,
    },
  };

  DoctorEntity toEntity() => DoctorEntity(
    id: id,
    email: email,
    username: username,
    gender: gender,
    imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
    birthDate: birthDate,
    phone: phone,
    firstName: firstName,
    lastName: lastName,
    age: age,
    jobTitle: jobTitle,
    specialties: specialties.isNotEmpty ? specialties : [specialization],
    experienceYears: experienceYears,
    bio: bio,
    sessionPrices: sessionPrices.map((price) => price.toEntity()).toList(),
    schedules: schedules.map((schedule) => schedule.toEntity()).toList(),
  );

  @override
  List<Object?> get props => [
    id,
    name,
    specialization,
    experience,
    rating,
    imageUrl,
    description,
    isOnline,
    ratingValue,
    createdAt,
    availableTimes,
    availableDurations,
    availableSessionTypes,
    consultationFee,
    email,
    username,
    gender,
    birthDate,
    phone,
    firstName,
    lastName,
    age,
    jobTitle,
    specialties,
    experienceYears,
    bio,
    sessionPrices,
    schedules,
  ];
}

String _composeName(
  String? firstName,
  String? lastName,
  String? username,
  Map<String, dynamic> json,
) {
  final parts = [
    firstName,
    lastName,
  ].whereType<String>().where((part) => part.trim().isNotEmpty).toList();
  if (parts.isNotEmpty) {
    return parts.join(' ');
  }

  final name = _readString(json['name']);
  if (name != null && name.isNotEmpty) {
    return name;
  }

  return username ?? '';
}

String _formatRating(double? ratingValue) {
  if (ratingValue == null || ratingValue <= 0) {
    return '';
  }
  return ratingValue.toStringAsFixed(1);
}

List<String> _parseSpecialties(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((item) {
        if (item is Map<String, dynamic>) {
          return _readString(item['name']);
        }
        return item?.toString();
      })
      .whereType<String>()
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

List<DoctorSessionPriceModel> _parseSessionPrices(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .whereType<Map>()
      .map(
        (item) =>
            DoctorSessionPriceModel.fromJson(item.cast<String, dynamic>()),
      )
      .where((item) => item.type.isNotEmpty)
      .toList();
}

List<DoctorScheduleModel> _parseSchedules(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .whereType<Map>()
      .map((item) => DoctorScheduleModel.fromJson(item.cast<String, dynamic>()))
      .where(
        (item) =>
            item.dayOfWeek.isNotEmpty ||
            item.startTime.isNotEmpty ||
            item.endTime.isNotEmpty,
      )
      .toList();
}

List<DateTime> _parseDateTimes(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((item) {
        if (item is DateTime) {
          return item;
        }
        return DateTime.tryParse(item.toString());
      })
      .whereType<DateTime>()
      .toList();
}

List<int> _parseInts(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((item) => _readInt(item))
      .whereType<int>()
      .where((item) => item > 0)
      .toList();
}

List<String> _parseSessionTypes(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value
      .map((item) => _normalizeSessionType(item?.toString() ?? ''))
      .where((item) => item.isNotEmpty)
      .toList();
}

// Legacy session-price synthesis removed: prices must come from backend `session_prices`.

ConsultationFee? _consultationFeeFromSessionPrices(
  List<DoctorSessionPriceModel> sessionPrices,
) {
  if (sessionPrices.isEmpty) {
    return null;
  }

  double pick(String type, double fallback) {
    for (final sessionPrice in sessionPrices) {
      if (sessionPrice.type == type) {
        return sessionPrice.price;
      }
    }
    return fallback;
  }

  return ConsultationFee(
    textChat: pick('text_chat', 10),
    videoCall: pick('video_call', 20),
    voiceCall: pick('voice_call', 15),
  );
}

List<DateTime> _deriveAvailableTimes(List<DoctorScheduleModel> schedules) {
  if (schedules.isEmpty) {
    return const [];
  }

  return schedules
      .map(
        (schedule) =>
            _nextOccurrenceForSchedule(schedule.dayOfWeek, schedule.startTime),
      )
      .whereType<DateTime>()
      .toList();
}

List<int> _deriveAvailableDurations(
  List<DoctorSessionPriceModel> sessionPrices,
  List<DoctorScheduleModel> schedules,
) {
  final durations = sessionPrices
      .map((sessionPrice) => sessionPrice.duration)
      .where((duration) => duration > 0)
      .toList();
  if (durations.isNotEmpty) {
    return durations;
  }

  return schedules
      .map((schedule) => _scheduleDurationMinutes(schedule))
      .whereType<int>()
      .where((duration) => duration > 0)
      .toList();
}

DateTime? _nextOccurrenceForSchedule(String dayOfWeek, String startTime) {
  final time = _parseScheduleTime(startTime);
  if (time == null) {
    return null;
  }

  final targetWeekday = _weekdayFromName(dayOfWeek);
  if (targetWeekday == null) {
    return time;
  }

  final now = DateTime.now();
  final base = DateTime(
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
    time.second,
    time.millisecond,
    time.microsecond,
  );
  var daysUntilTarget = targetWeekday - base.weekday;
  if (daysUntilTarget < 0) {
    daysUntilTarget += 7;
  }

  var candidate = base.add(Duration(days: daysUntilTarget));
  if (candidate.isBefore(now)) {
    candidate = candidate.add(const Duration(days: 7));
  }
  return candidate;
}

int? _scheduleDurationMinutes(DoctorScheduleModel schedule) {
  final start = _parseScheduleTime(schedule.startTime);
  final end = _parseScheduleTime(schedule.endTime);
  if (start == null || end == null) {
    return null;
  }

  final difference = end.difference(start).inMinutes;
  return difference > 0 ? difference : null;
}

DateTime? _parseScheduleTime(String value) {
  if (value.isEmpty) {
    return null;
  }

  final directParse = DateTime.tryParse(value);
  if (directParse != null) {
    return directParse;
  }

  return DateTime.tryParse('1970-01-01T$value');
}

int? _weekdayFromName(String dayOfWeek) {
  switch (dayOfWeek.trim().toLowerCase()) {
    case 'monday':
      return DateTime.monday;
    case 'tuesday':
      return DateTime.tuesday;
    case 'wednesday':
      return DateTime.wednesday;
    case 'thursday':
      return DateTime.thursday;
    case 'friday':
      return DateTime.friday;
    case 'saturday':
      return DateTime.saturday;
    case 'sunday':
      return DateTime.sunday;
    default:
      return null;
  }
}

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
  if (text == null || text.isEmpty) {
    return null;
  }
  return text;
}

bool? _readBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  final text = value?.toString().toLowerCase();
  if (text == null) {
    return null;
  }
  if (text == 'true' || text == '1') {
    return true;
  }
  if (text == 'false' || text == '0') {
    return false;
  }
  return null;
}

int? _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

double? _readDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _readDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  final text = value?.toString();
  if (text == null || text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text);
}
