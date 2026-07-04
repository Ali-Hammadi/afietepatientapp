import 'dart:async';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/appointments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appointments/domain/usecase/appointments_usecase.dart';
import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';
import 'package:afiete/feature/assessments/data/assisment_visibility_store.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  final GetAppointmentsUseCase getAppointmentsUseCase;
  final CreateAppointmentUseCase createAppointmentDraftUseCase;
  final GetAllDoctorsUseCase? getAllDoctorsUseCase;
  final CancelAppointmentUseCase cancelAppointmentUseCase;
  final RescheduleAppointmentUseCase rescheduleAppointmentUseCase;
  final GetAvailableSlotsUseCase getAvailableSlotsUseCase;

  Timer? _doctorRescheduleTimer;

  // ✅ إضافة متغيرات للـ Caching
  bool _isLoading = false;
  bool _hasLoadedOnce = false;
  List<DoctorEntity> _cachedDoctors = const [];

  AppointmentsCubit({
    required this.getAppointmentsUseCase,
    required this.createAppointmentDraftUseCase,
    this.getAllDoctorsUseCase,
    required this.cancelAppointmentUseCase,
    required this.rescheduleAppointmentUseCase,
    required this.getAvailableSlotsUseCase,
  }) : super(AppointmentsInitial());

  Future<void> loadAppointments({bool forceRefresh = false}) async {
    // ✅ منع التحميل المتكرر
    if (_isLoading) {
      print('⚠️ Already loading, skipping...');
      return;
    }

    // ✅ استخدام Cache
    if (_hasLoadedOnce && !forceRefresh) {
      print('✅ Using cached data');
      return;
    }

    _isLoading = true;
    emit(AppointmentsLoading());

    try {
      // ✅ جلب البيانات بالتوازي
      final results = await Future.wait([
        getAppointmentsUseCase(NoParams()),
        if (getAllDoctorsUseCase != null && _cachedDoctors.isEmpty)
          getAllDoctorsUseCase!(NoParams())
        else
          Future.value(const Right<List<DoctorEntity>, dynamic>([])),
      ]);

      final appointmentResult = results[0] as dynamic;

      // ✅ تحديث Cache الأطباء
      if (results.length > 1) {
        final doctorResult = results[1] as dynamic;
        doctorResult.fold(
          (_) {},
          (doctors) => _cachedDoctors = doctors,
        );
      }

      appointmentResult.fold(
        (failure) => emit(AppointmentsError(failure.errorMessage)),
        (appointmentsData) {
          _hasLoadedOnce = true;
          emit(
            AppointmentsLoaded(
              _sorted(appointmentsData.upcoming),
              _sorted(appointmentsData.past),
              _sorted(appointmentsData.missed),
              _sorted(appointmentsData.canceled),
              doctors: _cachedDoctors,
            ),
          );
        },
      );
    } catch (e) {
      emit(AppointmentsError('Failed to load appointments: $e'));
    } finally {
      _isLoading = false;
    }
  }

  // ✅ تغيير من 30 ثانية إلى 5 دقائق
  void startDoctorRescheduleListener() {
    _doctorRescheduleTimer?.cancel();
    _doctorRescheduleTimer = Timer.periodic(
      const Duration(minutes: 5), // ✅ 5 دقائق
      (timer) async {
        await _checkDoctorUpdatesInBackground();
      },
    );
  }

  void stopDoctorRescheduleListener() {
    _doctorRescheduleTimer?.cancel();
    _doctorRescheduleTimer = null;
  }

  Future<void> _checkDoctorUpdatesInBackground() async {
    final currentState = state;
    if (currentState is! AppointmentsLoaded) return;

    final result = await getAppointmentsUseCase(NoParams());
    result.fold(
      (_) => null,
      (appointmentsData) {
        bool structureChanged = false;
        AppointmentEntity? targetRescheduled;

        for (final fetched in appointmentsData.appointments) {
          final oldMatch = currentState.appointments.firstWhere(
            (old) => old.appointmentId == fetched.appointmentId,
            orElse: () => fetched,
          );

          if (oldMatch != fetched &&
              !oldMatch.scheduledAt.isAtSameMomentAs(fetched.scheduledAt)) {
            structureChanged = true;
            targetRescheduled = fetched;
            break;
          }
        }

        if (structureChanged && targetRescheduled != null) {
          emit(
            AppointmentsLoaded(
              _sorted(appointmentsData.upcoming),
              _sorted(appointmentsData.past),
              _sorted(appointmentsData.missed),
              _sorted(appointmentsData.canceled),
              doctors: currentState.doctors,
            ),
          );

          _triggerLocalNotification(targetRescheduled);
        }
      },
    );
  }

  List<AppointmentEntity> _sorted(List<AppointmentEntity> appointments) {
    final sorted = List<AppointmentEntity>.from(appointments);
    sorted.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return sorted;
  }

  void _triggerLocalNotification(AppointmentEntity appointment) {
    final dayName = DateFormat('EEEE', 'ar').format(appointment.scheduledAt);
    final timeStr = DateFormat('hh:mm a', 'ar').format(appointment.scheduledAt);

    final notificationMessage =
        "تم تغيير موعدك إلى يوم $dayName الساعة $timeStr.";

    print("NOTIFICATION TRIGGERED: $notificationMessage");
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
      (_) {
        AssessmentsVisibilityStore.markAssessmentsBooked();
        loadAppointments(forceRefresh: true);
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
        await loadAppointments(forceRefresh: true);
        return true;
      },
    );
  }

  Future<bool> rescheduleAppointment({
    required int appointmentId,
    required String doctorUsername,
    required DateTime newDate,
    required String slotStart,
    required String slotEnd,
  }) async {
    final result = await rescheduleAppointmentUseCase(
      RescheduleAppointmentParams(
        appointmentId: appointmentId,
        newScheduledAt: newDate,
        doctorUsername: doctorUsername,
        slotStart: slotStart,
        slotEnd: slotEnd,
      ),
    );

    return result.fold<Future<bool>>(
      (failure) {
        emit(AppointmentsError(failure.errorMessage));
        return Future.value(false);
      },
      (_) {
        loadAppointments(forceRefresh: true);
        return Future.value(true);
      },
    );
  }

  // ✅ دالة لمسح الـ Cache (اختياري)
  void clearCache() {
    _hasLoadedOnce = false;
    _cachedDoctors = const [];
  }
}
