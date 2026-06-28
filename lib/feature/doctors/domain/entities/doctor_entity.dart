import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';
import 'package:equatable/equatable.dart';

class DoctorTimeSlot extends Equatable {
  final String start;
  final String end;

  const DoctorTimeSlot({required this.start, required this.end});

  DateTime toStartDateTime(DateTime date) => _parse(start, date);
  DateTime toEndDateTime(DateTime date) => _parse(end, date);

  DateTime _parse(String t, DateTime d) {
    final parts = t.split(':');
    return DateTime(
        d.year, d.month, d.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String displayLabel() => '${_fmt(start)} – ${_fmt(end)}';

  String _fmt(String t) {
    final parts = t.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final dh = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$dh:$m $period';
  }

  @override
  List<Object> get props => [start, end];
}

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

class DoctorEntity extends Equatable {
  final String doctorUsername;
  final String? email;
  final String? gender;
  final String? imageUrl;
  final DateTime? birthDate;
  final String? phone;
  final String? name;
  final String? age;
  final String? jobTitle;
  final List<String> specialties;
  final int? experienceYears;
  final String? bio;
  final List<DoctorSessionPrice> sessionPrices;
  final List<DoctorSchedule> schedules;
  final String? patientsCount;
  final double? _ratingValue;
  final String? _rating;
  final String? _specialization;
  final String? _experience;

  const DoctorEntity({
    required this.doctorUsername,
    this.email,
    this.gender,
    this.imageUrl,
    this.birthDate,
    this.phone,
    this.name,
    this.age,
    this.jobTitle,
    this.specialties = const [],
    this.experienceYears,
    this.bio,
    this.sessionPrices = const [],
    this.schedules = const [],
    this.patientsCount,
    double? ratingValue,
    String? rating,
    String? specialization,
    String? experience,
  })  : _ratingValue = ratingValue,
        _rating = rating,
        _specialization = specialization,
        _experience = experience;

  // الـ Getters أصبحت تدعم القيم الممررة من المودل مع الحفاظ على القيم الافتراضية السابقة (Fallback) في حال كانت null
  String get specialization =>
      _specialization ??
      jobTitle ??
      (specialties.isNotEmpty ? specialties.first : '');

  String get experience =>
      _experience ?? (experienceYears != null ? '$experienceYears years' : '');

  String get rating =>
      _rating ??
      (_ratingValue != null ? _ratingValue.toStringAsFixed(1) : '5.0');

  String get description => bio ?? '';

  bool get isOnline => false;

  double get ratingValue => _ratingValue ?? 5.0;

  DateTime get createdAt => DateTime.now();

  List<DateTime> get availableTimes => _deriveAvailableTimes(schedules);

  List<int> get availableDurations =>
      _deriveAvailableDurations(sessionPrices, schedules);

  List<String> get availableSessionTypes =>
      sessionPrices.map((price) => price.type).toList();

  ConsultationFee get consultationFee =>
      _consultationFeeFromSessionPrices(sessionPrices) ??
      const ConsultationFee(textChat: 10, videoCall: 20, voiceCall: 15);

  DoctorEntity copyWith({
    String? username,
    String? email,
    String? gender,
    String? imageUrl,
    DateTime? birthDate,
    String? phone,
    String? name,
    String? age,
    String? jobTitle,
    List<String>? specialties,
    int? experienceYears,
    String? bio,
    List<DoctorSessionPrice>? sessionPrices,
    List<DoctorSchedule>? schedules,
    String? patients_count,
    double? ratingValue,
    String? rating,
    String? specialization,
    String? experience,
  }) {
    return DoctorEntity(
      doctorUsername: username ?? this.doctorUsername,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      imageUrl: imageUrl ?? this.imageUrl,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      age: age ?? this.age,
      jobTitle: jobTitle ?? this.jobTitle,
      specialties: specialties ?? this.specialties,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      sessionPrices: sessionPrices ?? this.sessionPrices,
      schedules: schedules ?? this.schedules,
      patientsCount: patients_count ?? this.patientsCount,
      ratingValue: ratingValue ?? this._ratingValue,
      rating: rating ?? this._rating,
      specialization: specialization ?? this._specialization,
      experience: experience ?? this._experience,
    );
  }

  @override
  List<Object?> get props => [
        doctorUsername,
        email,
        gender,
        imageUrl,
        birthDate,
        phone,
        name,
        age,
        jobTitle,
        specialties,
        experienceYears,
        bio,
        sessionPrices,
        schedules,
        patientsCount,
        _ratingValue,
        _rating,
        _specialization,
        _experience,
      ];
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
