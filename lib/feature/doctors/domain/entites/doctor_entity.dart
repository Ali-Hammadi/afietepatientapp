import 'package:afietepatientapp/feature/appoinments/domain/values/consultation_fee.dart';
import 'package:equatable/equatable.dart';

class DoctorSessionPrice extends Equatable {
  final int duration;
  final String type;
  final double price;

  const DoctorSessionPrice({
    required this.duration,
    required this.type,
    required this.price,
  });

  @override
  List<Object> get props => [duration, type, price];
}

class DoctorSchedule extends Equatable {
  final String id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  const DoctorSchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [id, dayOfWeek, startTime, endTime];
}

class DoctorEntity {
  final String id;
  final String? email;
  final String? username;
  final String? gender;
  final String? imageUrl;
  final DateTime? birthDate;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? age;
  final String? jobTitle;
  final List<String> specialties;
  final int? experienceYears;
  final String? bio;
  final List<DoctorSessionPrice> sessionPrices;
  final List<DoctorSchedule> schedules;

  DoctorEntity({
    required this.id,
    this.email,
    this.username,
    this.gender,
    this.imageUrl,
    this.birthDate,
    this.phone,
    this.firstName,
    this.lastName,
    this.age,
    this.jobTitle,
    this.specialties = const [],
    this.experienceYears,
    this.bio,
    this.sessionPrices = const [],
    this.schedules = const [],
  });

  String get name => _composeName(firstName, lastName, username, email ?? '');

  String get specialization =>
      jobTitle ?? (specialties.isNotEmpty ? specialties.first : '');

  String get experience =>
      experienceYears != null ? '$experienceYears years' : '';

  String get rating => '';

  String get description => bio ?? '';

  bool get isOnline => false;

  double get ratingValue => 0.0;

  DateTime get createdAt => DateTime.now();

  List<DateTime> get availableTimes => _deriveAvailableTimes(schedules);

  List<int> get availableDurations =>
      _deriveAvailableDurations(sessionPrices, schedules);

  List<String> get availableSessionTypes =>
      sessionPrices.map((price) => price.type).toList();

  ConsultationFee get consultationFee =>
      _consultationFeeFromSessionPrices(sessionPrices) ??
      const ConsultationFee(textChat: 10, videoCall: 20, voiceCall: 15);
}

String _composeName(
  String? firstName,
  String? lastName,
  String? username,
  String fallback,
) {
  final parts = [
    firstName,
    lastName,
  ].whereType<String>().where((part) => part.trim().isNotEmpty).toList();
  if (parts.isNotEmpty) {
    return parts.join(' ');
  }

  if (username != null && username.isNotEmpty) {
    return username;
  }

  return fallback;
}

List<DateTime> _deriveAvailableTimes(List<DoctorSchedule> schedules) {
  if (schedules.isEmpty) {
    return const [];
  }

  return schedules
      .map((schedule) => DateTime.tryParse(schedule.startTime))
      .whereType<DateTime>()
      .toList();
}

List<int> _deriveAvailableDurations(
  List<DoctorSessionPrice> sessionPrices,
  List<DoctorSchedule> schedules,
) {
  final durations = sessionPrices
      .map((sessionPrice) => sessionPrice.duration)
      .where((duration) => duration > 0)
      .toList();
  if (durations.isNotEmpty) {
    return durations;
  }

  return schedules
      .map((schedule) {
        final start = DateTime.tryParse(schedule.startTime);
        final end = DateTime.tryParse(schedule.endTime);
        if (start == null || end == null) {
          return null;
        }
        final duration = end.difference(start).inMinutes;
        return duration > 0 ? duration : null;
      })
      .whereType<int>()
      .toList();
}

ConsultationFee? _consultationFeeFromSessionPrices(
  List<DoctorSessionPrice> sessionPrices,
) {
  if (sessionPrices.isEmpty) {
    return null;
  }

  double pick(String type, double? fallback) {
    for (final sessionPrice in sessionPrices) {
      if (sessionPrice.type == type) {
        return sessionPrice.price;
      }
    }
    return fallback!;
  }

  return ConsultationFee(
    textChat: pick('text_chat', 10),
    videoCall: pick('video_call', 20),
    voiceCall: pick('voice_call', 15),
  );
}
