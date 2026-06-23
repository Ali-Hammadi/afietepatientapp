import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/appoinments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appoinments/domain/usecase/appointments_usecase.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';
import 'package:afiete/feature/assessments/data/assisment_visibility_store.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetAppointmentsUseCase getAppointmentsUseCase;
  final CreateAppointmentUseCase createAppointmentDraftUseCase;
  final GetAllDoctorsUseCase? getAllDoctorsUseCase;
  final CancelAppointmentUseCase cancelAppointmentUseCase;
  final RescheduleAppointmentUseCase rescheduleAppointmentUseCase;
  final GetAvailableSlotsUseCase getAvailableSlotsUseCase;

  AppointmentsCubit({
    required this.getAppointmentsUseCase,
    required this.createAppointmentDraftUseCase,
    this.getAllDoctorsUseCase,
    required this.cancelAppointmentUseCase,
    required this.rescheduleAppointmentUseCase,
    required this.getAvailableSlotsUseCase,
  }) : super(AppointmentsInitial());

  Future<void> loadAppointments() async {
    emit(AppointmentsLoading());
    final appointmentResult = await getAppointmentsUseCase(NoParams());

    List<DoctorEntity> doctorsList = const [];
    if (getAllDoctorsUseCase != null) {
      final doctorResult = await getAllDoctorsUseCase!(NoParams());
      doctorResult.fold((_) {}, (doctors) => doctorsList = doctors);
    }

    appointmentResult.fold(
      (failure) => emit(AppointmentsError(failure.errorMessage)),
      (appointments) {
        final sorted = List<AppointmentEntity>.from(appointments)
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        emit(AppointmentsLoaded(sorted, doctors: doctorsList));
      },
    );
  }

  Future<void> createAppointmentDraft({
    required int appointmentId,
    required String doctorUsername,
    required String patientUsername,
    required String doctorName,
    required DateTime scheduledAt,
    required int durationSlots,
    required ConsultationFee consultationFee,
    required String sessionType,
  }) async {
    emit(AppointmentsLoading());
    final result = await createAppointmentDraftUseCase(
      CreateAppointmentParams(
        appointmentId: appointmentId,
        doctorUsername: doctorUsername,
        patientUsername: patientUsername,
        doctorName: doctorName,
        scheduledAt: scheduledAt,
        durationSlots: durationSlots,
        consultationFee: consultationFee,
        sessionType: sessionType,
      ),
    );

    result.fold(
      (failure) => emit(AppointmentsError(failure.errorMessage)),
      (created) {
        AssessmentsVisibilityStore.markAssessmentsBooked();
        final currentState = state;
        if (currentState is AppointmentsLoaded) {
          final updated = [created, ...currentState.appointments]
            ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
          emit(AppointmentsLoaded(updated, doctors: currentState.doctors));
        } else {
          emit(AppointmentsLoaded([created], doctors: const []));
        }
      },
    );
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    emit(AppointmentsLoading());
    final result = await cancelAppointmentUseCase(
        CancelAppointmentParams(appointmentId: appointmentId));

    return result.fold<Future<bool>>(
      (failure) {
        emit(AppointmentsError(failure.errorMessage));
        return Future.value(false);
      },
      (_) async {
        await loadAppointments();
        return true;
      },
    );
  }

  Future<bool> rescheduleAppointment({
    required int appointmentId,
    required DateTime newScheduledAt,
  }) async {
    emit(AppointmentsLoading());
    final result = await rescheduleAppointmentUseCase(
      RescheduleAppointmentParams(
        appointmentId: appointmentId,
        newScheduledAt: newScheduledAt,
      ),
    );

    return result.fold<Future<bool>>(
      (failure) {
        emit(AppointmentsError(failure.errorMessage));
        return Future.value(false);
      },
      (_) async {
        await loadAppointments();
        return true;
      },
    );
  }
}
