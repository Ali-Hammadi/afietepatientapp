import 'package:afiete/feature/doctors/domain/entities/speciality_entity.dart'; // تأكد من صحة اسم الملف speciality أو specialty حسب مشروعك
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

  DoctorsCubit(
    this.getAllDoctorsUseCase,
    this.getDoctorsBySpecialtyUseCase,
    this.getDoctorByUsernameUseCase,
    this.getSpecialtiesUseCase,
  ) : super(const DoctorsInitial());

  List<SpecialtyEntity> _cachedSpecialties = [];
  int? _lastSpecialtyId;

  Future<void> initializeData() async {
    emit(const DoctorsLoading());

    final specialtiesResult = await getSpecialtiesUseCase(NoParams());
    specialtiesResult.fold(
      (failure) => emit(DoctorsError(failure.errorMessage)),
      (specialties) {
        _cachedSpecialties = specialties;
      },
    );

    if (state is DoctorsError) return;

    final doctorsResult = await getAllDoctorsUseCase(NoParams());
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
    _lastSpecialtyId = null; // إعادة التعيين عند طلب الجميع
    final result = await getAllDoctorsUseCase(NoParams());
    result.fold(
      (failure) => emit(DoctorsError(failure.errorMessage)),
      (doctors) => emit(DoctorsLoaded(doctors, _cachedSpecialties,
          selectedSpecialtyId: null)),
    );
  } // إصلاح: تم إغلاق الدالة هنا بنجاح وفصلها عن بقية الدوال الكلاسية

  Future<void> loadDoctorsBySpecialty(int specialtyId) async {
    emit(const DoctorsLoading());
    _lastSpecialtyId = specialtyId; // حفظ الـ ID لإعادة التحميل لاحقاً

    final result = await getDoctorsBySpecialtyUseCase(
      GetDoctorsBySpecialtyParams(
          specialtyId:
              specialtyId), // تأكد أن الاسم مطابق لما في الـ UseCase لديك (specialtyid أو specialtyId)
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
    if (_lastSpecialtyId == null) {
      await loadAllDoctors();
      return;
    }
    await loadDoctorsBySpecialty(_lastSpecialtyId!);
  }
}
