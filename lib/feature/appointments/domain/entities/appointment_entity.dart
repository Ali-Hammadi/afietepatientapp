import 'package:equatable/equatable.dart';
import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';

class AppointmentEntity extends Equatable {
  final dynamic appointmentId;
  final String doctorUsername;
  final String patientUsername;
  final String doctorName;
  final DateTime scheduledAt;
  final int durationSlots;
  final ConsultationFee consultationFee;
  final String sessionType;
  final String status;
  final bool requiresPayment;
  final bool hasNextSession;
  final String treatmentCourseId; // ✅ تم الإضافة

  const AppointmentEntity({
    required this.appointmentId,
    required this.doctorUsername,
    required this.patientUsername,
    required this.doctorName,
    required this.scheduledAt,
    required this.durationSlots,
    required this.consultationFee,
    required this.sessionType,
    required this.status,
    required this.requiresPayment,
    required this.hasNextSession,
    required this.treatmentCourseId, // ✅ تم الإضافة
  });

  DateTime get endAt => scheduledAt.add(Duration(minutes: durationSlots * 30));

  double get totalFee => consultationFee.getFeeBySType(sessionType);

  @override
  List<Object?> get props => [
        appointmentId,
        doctorUsername,
        patientUsername,
        doctorName,
        scheduledAt,
        durationSlots,
        consultationFee,
        sessionType,
        status,
        requiresPayment,
        hasNextSession,
        treatmentCourseId, // ✅ تم الإضافة
      ];
}
