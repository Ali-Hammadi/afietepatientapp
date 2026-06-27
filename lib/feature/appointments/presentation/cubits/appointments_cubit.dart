import 'dart:async'; // تم إضافة الـ Timer لبناء مستمع الخلفية
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/appointments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appointments/domain/usecase/appointments_usecase.dart';
import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';
import 'package:afiete/feature/assessments/data/assisment_visibility_store.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
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

  Timer? _doctorRescheduleTimer; // مؤقت الاستماع لتحديثات الطبيب

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
      (appointments) async {
        final sorted = List<AppointmentEntity>.from(appointments)
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
        emit(AppointmentsLoaded(sorted, doctors: doctorsList));
      },
    );
  }

  // بدء الاستماع للتغيرات القادمة من تطبيق الطبيب
  void startDoctorRescheduleListener() {
    _doctorRescheduleTimer?.cancel();
    _doctorRescheduleTimer =
        Timer.periodic(const Duration(seconds: 15), (timer) async {
      await _checkDoctorUpdatesInBackground();
    });
  }

  // إيقاف مستمع التغيرات عند مغادرة الشاشة لحفظ موارد الجهاز
  void stopDoctorRescheduleListener() {
    _doctorRescheduleTimer?.cancel();
    _doctorRescheduleTimer = null;
  }

  Future<void> _checkDoctorUpdatesInBackground() async {
    final currentState = state;
    if (currentState is! AppointmentsLoaded) return;

    final result = await getAppointmentsUseCase(NoParams());
    result.fold(
      (_) =>
          null, // تجاهل أخطاء الشبكة المؤقتة في الخلفية صمتاً لضمان استمرارية التجربة
      (fetchedAppointments) {
        bool structureChanged = false;
        AppointmentEntity? targetRescheduled;

        for (final fetched in fetchedAppointments) {
          final oldMatch = currentState.appointments.firstWhere(
            (old) => old.appointmentId == fetched.appointmentId,
            orElse: () => fetched,
          );

          // إذا كان الموعد موجوداً سابقاً ولكن طبيب قام بتعديل وقته وساعته
          if (oldMatch != fetched &&
              !oldMatch.scheduledAt.isAtSameMomentAs(fetched.scheduledAt)) {
            structureChanged = true;
            targetRescheduled = fetched;
            break;
          }
        }

        if (structureChanged && targetRescheduled != null) {
          final sorted = List<AppointmentEntity>.from(fetchedAppointments)
            ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

          emit(AppointmentsLoaded(sorted, doctors: currentState.doctors));

          _triggerLocalNotification(targetRescheduled);
        }
      },
    );
  }

  void _triggerLocalNotification(AppointmentEntity appointment) {
    final dayName = DateFormat('EEEE', 'ar').format(appointment.scheduledAt);
    final timeStr = DateFormat('hh:mm a', 'ar').format(appointment.scheduledAt);

    final notificationMessage =
        "تم تغيير موعدك إلى يوم $dayName الساعة $timeStr.";

    // هنا يتم استدعاء سرفيس الإشعارات الخاص بتطبيقك (مثال: flutter_local_notifications)
    // نضع طباعة تأكيدية كـ Interface بريزنتيشن نظيف جاهز للربط مباشرة
    // LocalNotificationService.show(title: "تحديث جدول المواعيد", body: notificationMessage);
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
    required String doctorUsername,
    required DateTime newDate,
    required String slotStart,
    required String slotEnd,
  }) async {
    final currentState = state;

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
      (updatedAppointment) {
        if (currentState is AppointmentsLoaded) {
          final updatedList = currentState.appointments.map((appointment) {
            return appointment.appointmentId == updatedAppointment.appointmentId
                ? updatedAppointment
                : appointment;
          }).toList()
            ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

          emit(AppointmentsLoaded(updatedList, doctors: currentState.doctors));
        } else {
          loadAppointments();
        }
        return Future.value(true);
      },
    );
  }
}
