import 'package:afiete/feature/appointments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.appointmentId,
    required super.doctorUsername,
    required super.patientUsername,
    required super.doctorName,
    required super.scheduledAt,
    required super.durationSlots,
    required super.consultationFee,
    required super.sessionType,
    required super.status,
    required super.requiresPayment,
    required super.hasNextSession,
    required super.treatmentCourseId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    String extractedUsername = 'unknown_doctor';
    String extractedDoctorName = 'Doctor';

    if (json['doctor_username'] != null) {
      extractedUsername = json['doctor_username'] as String;
    } else if (json['doctor'] is Map<String, dynamic>) {
      extractedUsername =
          json['doctor']['username'] as String? ?? 'unknown_doctor';
    }

    if (json['doctor_name'] != null) {
      extractedDoctorName = json['doctor_name'] as String;
    } else if (json['doctor'] is Map<String, dynamic>) {
      extractedDoctorName = json['doctor']['username'] as String? ?? 'Doctor';
    }

    // ✅ استخراج treatmentCourseId
    String treatmentCourseId = '';
    if (json['treatment_course_id'] != null) {
      treatmentCourseId = json['treatment_course_id'].toString();
    } else if (json['treatment_course'] != null &&
        json['treatment_course'] is Map<String, dynamic>) {
      treatmentCourseId = json['treatment_course']['id']?.toString() ?? '';
    }

    // ✅ معالجة الوقت - تحويل UTC من الـ backend لـ local للعرض
    DateTime parsedDate;
    if (json['date'] != null) {
      final dateStr = json['date'] as String;
      parsedDate = _parseDateTimeWithTimezone(dateStr); // ✅ استخدام نفس الاسم
    } else if (json['scheduledAt'] != null) {
      final dateStr = json['scheduledAt'] as String;
      parsedDate = _parseDateTimeWithTimezone(dateStr); // ✅ استخدام نفس الاسم
    } else {
      parsedDate = DateTime.now();
    }

    return AppointmentModel(
      appointmentId:
          json['id'] as dynamic ?? json['appointmentId'] as dynamic ?? 0,
      doctorUsername: extractedUsername,
      patientUsername: json['patient_username'] as String? ??
          json['patientId'] as String? ??
          'unknown_patient',
      doctorName: extractedDoctorName,
      scheduledAt: parsedDate, // ✅ الوقت المحلي للعرض
      durationSlots:
          json['duration_slots'] as int? ?? json['durationSlots'] as int? ?? 1,
      consultationFee:
          json['consultation_fee'] != null || json['consultationFee'] != null
              ? ConsultationFee(
                  textChat: ((json['consultation_fee']?['textChat'] ??
                          json['consultationFee']?['textChat'] ??
                          0) as num)
                      .toDouble(),
                  videoCall: ((json['consultation_fee']?['videoCall'] ??
                          json['consultationFee']?['videoCall'] ??
                          0) as num)
                      .toDouble(),
                  voiceCall: ((json['consultation_fee']?['voiceCall'] ??
                          json['consultationFee']?['voiceCall'] ??
                          0) as num)
                      .toDouble(),
                )
              : const ConsultationFee(textChat: 0, videoCall: 0, voiceCall: 0),
      sessionType: (json['type'] ?? json['sessionType'] ?? 'video') as String,
      status: (json['status'] ?? 'pending') as String,
      requiresPayment: json['requiresPayment'] as bool? ?? false,
      hasNextSession: json['has_next_session'] as bool? ?? false,
      treatmentCourseId: treatmentCourseId,
    );
  }

  // ✅ دالة مساعدة لتحويل UTC من الـ backend لـ local
  static DateTime _parseDateTimeWithTimezone(String dateStr) {
    // ✅ إذا كان الـ string ما فيه timezone info، نفترض إنه UTC
    String normalizedStr = dateStr;
    if (!dateStr.endsWith('Z') &&
        !dateStr.contains('+') &&
        !dateStr.substring(10).contains('-')) {
      normalizedStr = '${dateStr}Z'; // ✅ إضافة Z ليدل على UTC
    }

    final parsed = DateTime.parse(normalizedStr);

    // ✅ إذا كان UTC، نحوله لـ local للعرض
    if (parsed.isUtc) {
      return parsed.toLocal();
    }

    return parsed;
  }

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      appointmentId: entity.appointmentId,
      doctorUsername: entity.doctorUsername,
      patientUsername: entity.patientUsername,
      doctorName: entity.doctorName,
      scheduledAt: entity.scheduledAt,
      durationSlots: entity.durationSlots,
      consultationFee: entity.consultationFee,
      sessionType: entity.sessionType,
      status: entity.status,
      requiresPayment: entity.requiresPayment,
      hasNextSession: entity.hasNextSession,
      treatmentCourseId: entity.treatmentCourseId,
    );
  }
}
