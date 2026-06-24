import 'package:equatable/equatable.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';

class AppointmentEntity extends Equatable {
  final dynamic appointmentId;
  final String doctorUsername;
  final String patientId;
  final String doctorName;
  final DateTime scheduledAt;
  final int durationSlots;
  final ConsultationFee consultationFee;
  final String sessionType;
  final String status;
  final bool requiresPayment;
  final bool hasNextSession; // تم الإضافة هنا

  const AppointmentEntity({
    required this.appointmentId,
    required this.doctorUsername,
    required this.patientId,
    required this.doctorName,
    required this.scheduledAt,
    required this.durationSlots,
    required this.consultationFee,
    required this.sessionType,
    required this.status,
    required this.requiresPayment,
    required this.hasNextSession, // تم الإضافة هنا
  });

  DateTime get endAt => scheduledAt.add(Duration(minutes: durationSlots * 30));

  double get totalFee => consultationFee.getFeeBySType(sessionType);

  @override
  List<Object?> get props => [
        appointmentId,
        doctorUsername,
        patientId,
        doctorName,
        scheduledAt,
        durationSlots,
        consultationFee,
        sessionType,
        status,
        requiresPayment,
        hasNextSession, // تم الإضافة هنا
      ];
}
