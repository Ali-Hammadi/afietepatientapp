import 'package:afiete/feature/appoinments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';

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
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointmentId: json['id'] as int? ?? json['appointmentId'] as int? ?? 0,
      doctorUsername: json['doctor_username'] as String? ?? 'unknown_doctor',
      patientId: json['patient_username'] as String? ??
          json['patientId'] as String? ??
          'unknown_patient',
      doctorName: (json['doctor_name'] ?? json['doctor_username'] ?? 'Doctor')
          as String,
      scheduledAt: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : json['scheduledAt'] != null
              ? DateTime.parse(json['scheduledAt'] as String)
              : DateTime.now(),
      durationSlots:
          json['durationSlots'] as int? ?? json['duration_slots'] as int? ?? 1,
      consultationFee: json['consultationFee'] != null
          ? ConsultationFee(
              textChat: (json['consultationFee']['textChat'] as num).toDouble(),
              videoCall:
                  (json['consultationFee']['videoCall'] as num).toDouble(),
              voiceCall:
                  (json['consultationFee']['voiceCall'] as num).toDouble(),
            )
          : const ConsultationFee(textChat: 0, videoCall: 0, voiceCall: 0),
      sessionType: (json['type'] ?? json['sessionType'] ?? 'video') as String,
      status: (json['status'] ?? 'pending') as String,
      requiresPayment: json['requiresPayment'] as bool? ?? false,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': appointmentId,
      'doctor_username': doctorUsername,
      'patient_username': patientId,
      'doctor_name': doctorName,
      'date': scheduledAt.toIso8601String(),
      'duration_slots': durationSlots,
      'consultation_fee': {
        'textChat': consultationFee.textChat,
        'videoCall': consultationFee.videoCall,
        'voiceCall': consultationFee.voiceCall,
      },
      'type': sessionType,
      'status': status,
      'requiresPayment': requiresPayment,
    };
  }
}
