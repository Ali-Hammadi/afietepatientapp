import 'package:equatable/equatable.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';

class AppointmentEntity extends Equatable {
  final int appointmentId; // تعديل إلى int
  final String doctorUsername;
  final String patientId;
  final String doctorName;
  final DateTime scheduledAt;
  final int durationSlots;
  final ConsultationFee consultationFee;
  final String sessionType;
  final String status;
  final bool requiresPayment;

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
      ];
}
