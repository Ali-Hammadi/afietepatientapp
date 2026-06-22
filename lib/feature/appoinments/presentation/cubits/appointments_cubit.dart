import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/assisments/data/assisment_visibility_store.dart';
import 'package:afiete/feature/appoinments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appoinments/domain/usecase/appointments_usecase.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ

part 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetAppointmentsUseCase getAppointmentsUseCase;
  final CreateAppointmentUseCase createAppointmentDraftUseCase;
  final GetAllDoctorsUseCase? getAllDoctorsUseCase;
  final CancelAppointmentUseCase cancelAppointmentUseCase;
  final RescheduleAppointmentUseCase rescheduleAppointmentUseCase;
  // إضافة UseCase الجديد
  final GetAvailableSlotsUseCase getAvailableSlotsUseCase;

  AppointmentsCubit(
    this.getAppointmentsUseCase,
    this.createAppointmentDraftUseCase,
    this.getAllDoctorsUseCase,
    this.cancelAppointmentUseCase,
    this.rescheduleAppointmentUseCase,
    this.getAvailableSlotsUseCase, // إضافة في الـ Constructor
  ) : super(const AppointmentsInitial());

  // --- الدالة الجديدة لجلب الأوقات ---
  Future<void> fetchAvailableSlots({
    required String doctorUsername,
    required DateTime date,
  }) async {
    // يجب إضافة SlotsLoading إلى ملف state
    emit(const SlotsLoading());

    // تحويل التاريخ للصيغة التي يقبلها Django
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final result = await getAvailableSlotsUseCase(
      GetAvailableSlotsParams(
        doctorUsername: doctorUsername,
        date: formattedDate,
      ),
    );

    result.fold(
      (failure) => emit(AppointmentsError(failure.errorMessage)),
      (slots) => emit(SlotsLoaded(slots)), // تأكد من وجود SlotsLoaded في state
    );
  }

  // --- باقي الدوال كما هي ---

  Future<void> loadAppointments() async {
    emit(const AppointmentsLoading());
    final appointmentsResult = await getAppointmentsUseCase(NoParams());
    final doctorsUseCase = getAllDoctorsUseCase;

    final appointments = appointmentsResult.fold<List<AppointmentEntity>?>((
      failure,
    ) {
      emit(AppointmentsError(failure.errorMessage));
      return null;
    }, (appointments) => appointments);

    if (appointments == null) {
      return;
    }

    if (doctorsUseCase == null) {
      emit(AppointmentsLoaded(appointments, doctors: const []));
      return;
    }

    final doctorsResult = await doctorsUseCase(NoParams());
    doctorsResult.fold(
      (_) => emit(AppointmentsLoaded(appointments, doctors: const [])),
      (doctors) => emit(AppointmentsLoaded(appointments, doctors: doctors)),
    );
  }

  Future<void> createBookingDraft({
    required String doctorUsername,
    required String patientUsername,
    required String doctorName,
    required DateTime scheduledAt,
    required int durationSlots,
    required ConsultationFee consultationFee,
    required String sessionType,
  }) async {
    final result = await createAppointmentDraftUseCase(
      CreateAppointmentParams(
        doctorUsername: doctorUsername,
        patientUsername: patientUsername,
        doctorName: doctorName,
        scheduledAt: scheduledAt,
        durationSlots: durationSlots,
        consultationFee: consultationFee,
        sessionType: sessionType,
      ),
    );

    await result.fold<Future<void>>(
      (failure) async {
        emit(AppointmentsError(failure.errorMessage));
      },
      (created) async {
        await AssismentVisibilityStore.markAssismentBooked();
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

  Future<bool> cancelAppointment(String appointmentId) async {
    final result = await cancelAppointmentUseCase(
      CancelAppointmentParams(appointmentId: appointmentId),
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

  Future<bool> rescheduleAppointment({
    required String appointmentId,
    required DateTime newScheduledAt,
  }) async {
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
