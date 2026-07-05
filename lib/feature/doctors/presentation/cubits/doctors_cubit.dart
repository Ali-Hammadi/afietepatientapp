import 'package:afiete/feature/appointments/domain/usecase/appointments_usecase.dart';
import 'package:afiete/feature/doctors/domain/entities/speciality_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:intl/intl.dart';

part 'doctors_state.dart';

class DoctorsCubit extends Cubit<DoctorsState> {
  final GetAllDoctorsUseCase getAllDoctorsUseCase;
  final GetDoctorsBySpecialtyUseCase getDoctorsBySpecialtyUseCase;
  final GetDoctorByUsernameUseCase getDoctorByUsernameUseCase;
  final GetSpecialtiesUseCase getSpecialtiesUseCase;
  final GetAvailableSlotsUseCase getAvailableSlotsUseCase; // ✅ إضافة

  DoctorsCubit(
    this.getAllDoctorsUseCase,
    this.getDoctorsBySpecialtyUseCase,
    this.getDoctorByUsernameUseCase,
    this.getSpecialtiesUseCase,
    this.getAvailableSlotsUseCase, // ✅ إضافة
  ) : super(const DoctorsInitial());

  List<SpecialtyEntity> _cachedSpecialties = [];
  int? _lastSpecialtyId;

  Future<void> initializeData() async {
    emit(const DoctorsLoading());

    // 1. أول عملية await (جلب التخصصات)
    final specialtiesResult = await getSpecialtiesUseCase(NoParams());

    if (isClosed) return;

    specialtiesResult.fold(
      (failure) => emit(DoctorsError(failure.errorMessage)),
      (specialties) {
        _cachedSpecialties = specialties;
      },
    );

    if (state is DoctorsError) return;

    // 2. ثاني عملية await (جلب الأطباء)
    final doctorsResult = await getAllDoctorsUseCase(NoParams());

    if (isClosed) return;

    doctorsResult.fold(
      (failure) => emit(DoctorsError(failure.errorMessage)),
      (doctors) {
        _lastSpecialtyId = null;
        emit(DoctorsLoaded(doctors, _cachedSpecialties,
            selectedSpecialtyId: null));
      },
    );
  }

  Future<void> loadAllDoctors() async {
    emit(const DoctorsLoading());
    _lastSpecialtyId = null;

    final result = await getAllDoctorsUseCase(NoParams());

    if (isClosed) return;

    result.fold(
      (failure) => emit(DoctorsError(failure.errorMessage)),
      (doctors) => emit(DoctorsLoaded(
        doctors,
        _cachedSpecialties,
        selectedSpecialtyId: null,
      )),
    );
  }

  Future<void> loadDoctorsBySpecialty(int specialtyId) async {
    emit(const DoctorsLoading());
    _lastSpecialtyId = specialtyId;

    final result = await getDoctorsBySpecialtyUseCase(
      GetDoctorsBySpecialtyParams(specialtyId: specialtyId),
    );

    result.fold(
      (failure) => emit(DoctorsError(failure.errorMessage)),
      (doctors) => emit(DoctorsLoaded(doctors, _cachedSpecialties,
          selectedSpecialtyId: specialtyId)),
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
    String doctorUsername,
    DateTime date,
  ) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    try {
      final result = await getAvailableSlotsUseCase(
        GetAvailableSlotsParams(
          doctorUsername: doctorUsername,
          date: dateStr,
        ),
      );

      return result.fold(
        (failure) {
          print('❌ Failed to fetch slots: ${failure.errorMessage}');
          return <DoctorTimeSlot>[];
        },
        (slots) {
          // ✅ تحويل List<dynamic> إلى List<DoctorTimeSlot>
          return slots.map((slot) {
            if (slot is Map<String, dynamic>) {
              return DoctorTimeSlot.fromJson(slot);
            } else if (slot is DoctorTimeSlot) {
              return slot;
            }
            return const DoctorTimeSlot(start: '', end: '');
          }).toList();
        },
      );
    } catch (e) {
      print('❌ Error fetching slots: $e');
      return <DoctorTimeSlot>[];
    }
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
    if (_lastSpecialtyId == null) {
      await loadAllDoctors();
      return;
    }
    await loadDoctorsBySpecialty(_lastSpecialtyId!);
  }
}
