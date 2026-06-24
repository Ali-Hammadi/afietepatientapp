import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/appoinments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';
import 'package:dartz/dartz.dart';

abstract class AppointmentsRepository {
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments();

  Future<Either<Failure, List<dynamic>>> getAvailableSlots({
    required String doctorUsername,
    required String date,
  });

  Future<Either<Failure, AppointmentEntity>> createAppointment({
    required dynamic appointmentId,
    required String doctorUsername,
    required String patientUsername,
    required String doctorName,
    required DateTime scheduledAt,
    required int durationSlots,
    required ConsultationFee consultationFee,
    required String sessionType,
  });

  Future<Either<Failure, void>> cancelAppointment(dynamic appointmentId);

  Future<Either<Failure, AppointmentEntity>> rescheduleAppointment({
    required int appointmentId,
    required String doctorUsername,
    required DateTime newDate,
    required String slotStart,
    required String slotEnd,
  });
}
