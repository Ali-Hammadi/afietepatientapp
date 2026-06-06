import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:intl/intl.dart';

part 'doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final GetAllDoctorsUseCase getAllDoctorsUseCase;
  final GetDoctorsBySpecialtyUseCase getDoctorsBySpecialtyUseCase;
  final GetDoctorByUsernameUseCase getDoctorByUsernameUseCase;
  String? _lastSpecialty;

  DoctorsCubit(
    this.getAllDoctorsUseCase,
    this.getDoctorsBySpecialtyUseCase,
    this.getDoctorByUsernameUseCase,
  ) : super(const DoctorsInitial());

  Future<void> loadAllDoctors() async {
    emit(const DoctorsLoading());
    _lastSpecialty = null;
    final result = await getAllDoctorsUseCase(NoParams());
    result.fold(
      (failure) => emit(DoctorsError(failure.errorMessage)),
      (doctors) => emit(DoctorsLoaded(doctors, null)),
    );
  }

  Future<void> loadDoctorsBySpecialty(String specialty) async {
    emit(const DoctorsLoading());
    _lastSpecialty = specialty;
    final result = await getDoctorsBySpecialtyUseCase(
      GetDoctorsBySpecialtyParams(specialty: specialty),
    );
    result.fold(
      (failure) => emit(DoctorsError(failure.errorMessage)),
      (doctors) => emit(DoctorsLoaded(doctors, specialty)),
    );
  }

  Future<void> loadDoctorByUsername(String username) async {
    emit(const DoctorLoading());

    final repository = getDoctorByUsernameUseCase.repository;
    final profileResult = await repository.getDoctorPublicProfile(username);

    DoctorEntity baseDoctor;

    if (profileResult.isRight()) {
      baseDoctor =
          profileResult.getOrElse(() => DoctorEntity(doctorUsername: username));
    } else {
      final fallbackResult = await getDoctorByUsernameUseCase(
        GetDoctorByUsernameParams(username: username),
      );
      if (fallbackResult.isLeft()) {
        fallbackResult.fold(
          (failure) => emit(DoctorError(failure.errorMessage)),
          (_) => null,
        );
        return;
      }
      baseDoctor = fallbackResult
          .getOrElse(() => DoctorEntity(doctorUsername: username));
      baseDoctor = await _mergeDoctorScheduleIfNeeded(baseDoctor);
    }

    emit(DoctorLoaded(baseDoctor));
  }

  Future<List<DoctorTimeSlot>> fetchSlotsForDate(
    String username,
    DateTime date,
  ) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final result = await getDoctorByUsernameUseCase.repository
        .getDoctorAvailableSlots(username, dateStr);
    return result.getOrElse(() => const <DoctorTimeSlot>[]);
  }

  Future<DoctorEntity> _mergeDoctorScheduleIfNeeded(
    DoctorEntity doctor,
  ) async {
    if (doctor.schedules.isNotEmpty || doctor.doctorUsername.isEmpty) {
      return doctor;
    }

    final scheduleResult = await getDoctorByUsernameUseCase.repository
        .getDoctorScheduleById(doctor.doctorUsername);

    return scheduleResult.fold(
      (_) => doctor,
      (schedule) => doctor.copyWith(schedules: [schedule]),
    );
  }

  Future<void> reloadCurrent() async {
    if (_lastSpecialty == null) {
      await loadAllDoctors();
      return;
    }

    await loadDoctorsBySpecialty(_lastSpecialty!);
  }
}
