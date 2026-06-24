import 'package:afiete/core/error/failure.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/appoinments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appoinments/domain/repositories/appointments_repository.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';
import 'package:dartz/dartz.dart';

class CreateAppointmentParams {
  final dynamic appointmentId;
  final String doctorUsername;
  final String patientUsername;
  final String doctorName;
  final DateTime scheduledAt;
  final int durationSlots;
  final ConsultationFee consultationFee;
  final String sessionType;

  const CreateAppointmentParams({
    required this.appointmentId,
    required this.doctorUsername,
    required this.patientUsername,
    required this.doctorName,
    required this.scheduledAt,
    required this.durationSlots,
    required this.consultationFee,
    required this.sessionType,
  });
}

class CreateAppointmentUseCase
    implements UseCase<AppointmentEntity, CreateAppointmentParams> {
  final AppointmentsRepository repository;

  const CreateAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, AppointmentEntity>> call(
      CreateAppointmentParams params) {
    return repository.createAppointment(
      appointmentId: params.appointmentId,
      doctorUsername: params.doctorUsername,
      patientUsername: params.patientUsername,
      doctorName: params.doctorName,
      scheduledAt: params.scheduledAt,
      durationSlots: params.durationSlots,
      consultationFee: params.consultationFee,
      sessionType: params.sessionType,
    );
  }
}

//==================================================================================================
class GetAppointmentsUseCase
    implements UseCase<List<AppointmentEntity>, NoParams> {
  final AppointmentsRepository repository;

  const GetAppointmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(NoParams params) {
    return repository.getAppointments();
  }
}

//==================================================================================================
class CancelAppointmentParams {
  final dynamic appointmentId;
  const CancelAppointmentParams({required this.appointmentId});
}
//==================================================================================================

class CancelAppointmentUseCase
    implements UseCase<void, CancelAppointmentParams> {
  final AppointmentsRepository repository;
  const CancelAppointmentUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(CancelAppointmentParams params) {
    return repository.cancelAppointment(
      params.appointmentId,
    );
  }
}

//==================================================================================================
class RescheduleAppointmentParams {
  final dynamic appointmentId;
  final DateTime newScheduledAt;
  final String doctorUsername;
  final String slotStart;
  final String slotEnd;
  const RescheduleAppointmentParams({
    required this.appointmentId,
    required this.newScheduledAt,
    required this.doctorUsername,
    required this.slotStart,
    required this.slotEnd,
  });
}

//==================================================================================================
class RescheduleAppointmentUseCase
    implements UseCase<AppointmentEntity, RescheduleAppointmentParams> {
  final AppointmentsRepository repository;
  const RescheduleAppointmentUseCase(this.repository);
  @override
  Future<Either<Failure, AppointmentEntity>> call(
    RescheduleAppointmentParams params,
  ) {
    return repository.rescheduleAppointment(
      appointmentId: params.appointmentId,
      newDate: params.newScheduledAt,
      doctorUsername: params.doctorUsername,
      slotStart: params.slotStart,
      slotEnd: params.slotEnd,
    );
  }
}

//==================================================================================================
class GetAvailableSlotsParams {
  final String doctorUsername;
  final String date;
  const GetAvailableSlotsParams({
    required this.doctorUsername,
    required this.date,
  });
}

//==================================================================================================
class GetAvailableSlotsUseCase
    implements UseCase<List<dynamic>, GetAvailableSlotsParams> {
  final AppointmentsRepository repository;
  const GetAvailableSlotsUseCase(this.repository);
  @override
  Future<Either<Failure, List<dynamic>>> call(
    GetAvailableSlotsParams params,
  ) {
    return repository.getAvailableSlots(
      doctorUsername: params.doctorUsername,
      date: params.date,
    );
  }
}
//==================================================================================================
