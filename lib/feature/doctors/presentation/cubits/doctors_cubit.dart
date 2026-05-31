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
    final result = await getDoctorByIdUseCase(GetDoctorByIdParams(id: id));
    result.fold((failure) => emit(DoctorError(failure.errorMessage)), (
      doctor,
    ) async {
      final mergedDoctor = await _mergeDoctorScheduleIfNeeded(doctor);
      emit(DoctorLoaded(mergedDoctor));
    });
  }

  Future<DoctorEntity> _mergeDoctorScheduleIfNeeded(DoctorEntity doctor) async {
    if (doctor.schedules.isNotEmpty || doctor.id.isEmpty) {
      return doctor;
    }

    final scheduleResult = await getDoctorByIdUseCase.repository
        .getDoctorScheduleById(doctor.id);

    return scheduleResult.fold(
      (_) => doctor,
      (schedule) => _withSchedule(doctor, schedule),
    );
  }

  DoctorEntity _withSchedule(
    DoctorEntity doctor,
    DoctorSchedule schedule,
  ) {
    return DoctorEntity(
      id: doctor.id,
      email: doctor.email,
      username: doctor.username,
      gender: doctor.gender,
      birthDate: doctor.birthDate,
      phone: doctor.phone,
      firstName: doctor.firstName,
      lastName: doctor.lastName,
      age: doctor.age,
      jobTitle: doctor.jobTitle,
      specialties: doctor.specialties,
      experienceYears: doctor.experienceYears,
      bio: doctor.bio,
      sessionPrices: doctor.sessionPrices,
      schedules: [schedule],
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
