import 'package:afiete/feature/appoinments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
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
      id: (json['id'] ?? '').toString(),
      // الـ Django يرسل doctor_username، نستخدمه كـ doctorId و doctorName مؤقتاً إذا لم تتوفر IDs منفصلة
      doctorUsername: json['doctor_username'] as String? ?? 'unknown_doctor',
      patientId: json['patient_username'] as String? ??
          json['patientId'] as String? ??
          'unknown_patient',
      doctorName:
          (json['doctor_username'] ?? json['doctorName'] ?? 'Doctor') as String,

      // الـ Django يرسل التاريخ بمفتاح 'date'
      scheduledAt: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.parse(json['scheduledAt'] as String? ??
              DateTime.now().toIso8601String()),

      // تحويل الـ duration القادم من السيرفر إلى slots (مثلاً تقسيم المدة أو وضع قيمة افتراضية)
      durationSlots: json['durationSlots'] as int? ?? 1,

      // الـ Django لا يرسل أسعار المواعيد في هذا الـ Endpoint، نضع كائن افتراضي لتجنب الـ Null
      consultationFee: json['consultationFee'] != null
          ? ConsultationFee(
              textChat: (json['consultationFee']['textChat'] as num).toDouble(),
              videoCall:
                  (json['consultationFee']['videoCall'] as num).toDouble(),
              voiceCall:
                  (json['consultationFee']['voiceCall'] as num).toDouble(),
            )
          : const ConsultationFee(textChat: 0, videoCall: 0, voiceCall: 0),

      // الـ Django يرسل نوع الجلسة بمفتاح 'type'
      sessionType: (json['type'] ?? json['sessionType'] ?? 'video') as String,
      status: (json['status'] ?? 'pending') as String,
      requiresPayment: json['requiresPayment'] as bool? ?? false,
    );
  }
  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
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
      'id': id,
      'doctorUsername': doctorUsername,
      'patientId': patientId,
      'doctorName': doctorName,
      'scheduledAt': scheduledAt.toIso8601String(),
      'durationSlots': durationSlots,
      'consultationFee': {
        'textChat': consultationFee.textChat,
        'videoCall': consultationFee.videoCall,
        'voiceCall': consultationFee.voiceCall,
      },
      'sessionType': sessionType,
      'status': status,
      'requiresPayment': requiresPayment,
    };
  }
}
