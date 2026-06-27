import 'package:afiete/feature/appointments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.appointmentId,
    required super.doctorUsername,
    required super.patientId,
    required super.doctorName,
    required super.scheduledAt,
    required super.durationSlots,
    required super.consultationFee,
    required super.sessionType,
    required super.status,
    required super.requiresPayment,
    required super.hasNextSession,
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

    return AppointmentModel(
      appointmentId:
          json['id'] as dynamic ?? json['appointmentId'] as dynamic ?? 0,
      doctorUsername: extractedUsername,
      patientId: json['patient_username'] as String? ??
          json['patientId'] as String? ??
          'unknown_patient',
      doctorName: extractedDoctorName,
      scheduledAt: json['date'] != null
          ? DateTime.parse(json['date'] as String).toUtc()
          : json['scheduledAt'] != null
              ? DateTime.parse(json['scheduledAt'] as String).toUtc() // 🟢
              : DateTime.now(),
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
      hasNextSession:
          json['has_next_session'] as bool? ?? false, // تم استخراج القيمة
    );
  }

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      appointmentId: entity.appointmentId,
      doctorUsername: entity.doctorUsername,
      patientId: entity.patientId,
      doctorName: entity.doctorName,
      scheduledAt: entity.scheduledAt,
      durationSlots: entity.durationSlots,
      consultationFee: entity.consultationFee,
      sessionType: entity.sessionType,
      status: entity.status,
      requiresPayment: entity.requiresPayment,
      hasNextSession: entity.hasNextSession,
    );
  }
}
