import 'package:equatable/equatable.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';

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
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    // قراءة البيانات المتداخلة من كائن الـ user إن وجد
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;

    // استخراج الـ username بأي صيغة متوقعة من الباك-أند
    final username = _readString(json['username'] ??
            json['doctor_username'] ??
            userMap?['username']) ??
        '';

    // استخراج الاسم أو دمجه من الاسم الأول والأخير للـ user
    String name = _readString(json['name']) ?? '';
    if (name.isEmpty && userMap != null) {
      final firstName = _readString(userMap['first_name']) ?? '';
      final lastName = _readString(userMap['last_name']) ?? '';
      name = '$firstName $lastName'.trim();
    }
    if (name.isEmpty) {
      name = username;
    }

    // معالجة أسعار الجلسات بشكل آمن ضد الأخطاء
    final rawPrices = json['session_prices'] ?? json['prices'] ?? const [];
    final prices = rawPrices is List
        ? rawPrices
            .map((e) =>
                DoctorSessionPriceModel.fromJson(e as Map<String, dynamic>)
                    .toEntity())
            .toList()
        : const <DoctorSessionPrice>[];

    // معالجة مواعيد عمل الطبيب بشكل آمن ضد الأخطاء
    final rawSchedules = json['schedules'] ?? json['schedule'] ?? const [];
    final schedules = rawSchedules is List
        ? rawSchedules
            .map((e) => DoctorScheduleModel.fromJson(e as Map<String, dynamic>)
                .toEntity())
            .toList()
        : const <DoctorSchedule>[];

    return DoctorModel(
      doctorUsername: username,
      name: name,
      specialties:
          (json['specialties'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
      bio: _readString(json['bio'] ?? json['description']) ?? '',
      imageUrl: _readString(json['profile_picture'] ?? json['image']) ?? '',
      sessionPrices: prices,
      schedules: schedules,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': doctorUsername,
      'name': name,
      'specialties': specialties,
      'bio': bio,
      'profile_picture': imageUrl,
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

// دالات مساعدة (Helper Utilities) لضمان استقرار قراءة البيانات وحمايتها من الـ Null:
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
