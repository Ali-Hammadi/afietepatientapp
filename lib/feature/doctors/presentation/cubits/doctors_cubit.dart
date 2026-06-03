import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afietepatientapp/feature/doctors/domain/usecase/get_doctors_usecase.dart';

part 'doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final GetAllDoctorsUseCase getAllDoctorsUseCase;
  final GetDoctorsBySpecialtyUseCase getDoctorsBySpecialtyUseCase;
  final GetDoctorByIdUseCase getDoctorByIdUseCase;
  String? _lastSpecialty;

  DoctorsCubit(
    this.getAllDoctorsUseCase,
    this.getDoctorsBySpecialtyUseCase,
    this.getDoctorByIdUseCase,
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

  Future<void> loadDoctorById(String id) async {
    emit(const DoctorLoading());

    final repository = getDoctorByIdUseCase.repository;

    final profileResult = await repository.getDoctorPublicProfile(id);
    final slotsResult = await repository.getDoctorAvailableSlots(id);

    DoctorEntity baseDoctor;

    if (profileResult.isRight()) {
      baseDoctor = profileResult.getOrElse(
        () => DoctorEntity(id: id),
      );
    } else {
      final fallbackResult = await getDoctorByIdUseCase(
        GetDoctorByIdParams(id: id),
      );
      if (fallbackResult.isLeft()) {
        fallbackResult.fold(
          (failure) => emit(DoctorError(failure.errorMessage)),
          (_) => null,
        );
        return;
      }
      baseDoctor = fallbackResult.getOrElse(() => DoctorEntity(id: id));
      baseDoctor = await _mergeDoctorScheduleIfNeeded(baseDoctor);
    }

    final slots = slotsResult.getOrElse(() => const <DateTime>[]);
    final mergedDoctor = slots.isNotEmpty
        ? baseDoctor.copyWith(externalAvailableSlots: slots)
        : baseDoctor;

    emit(DoctorLoaded(mergedDoctor));
  }

  Future<DoctorEntity> _mergeDoctorScheduleIfNeeded(DoctorEntity doctor) async {
    if (doctor.schedules.isNotEmpty || doctor.id.isEmpty) {
      return doctor;
    }

    final scheduleResult = await getDoctorByIdUseCase.repository
        .getDoctorScheduleById(doctor.id);

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
