import 'package:dartz/dartz.dart';
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/entities/speciality_entity.dart';
import 'package:afiete/feature/doctors/domain/repositories/doctors_repository.dart';

class GetAllDoctorsUseCase implements UseCase<List<DoctorEntity>, NoParams> {
  final DoctorsRepository repository;

  const GetAllDoctorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(NoParams params) {
    return repository.getAllDoctors();
  }
}

// تعديل الـ Params لتأخذ المعرّف الرقمي
class GetDoctorsBySpecialtyParams {
  final int specialtyId;

  const GetDoctorsBySpecialtyParams({required this.specialtyId});
}

class GetDoctorsBySpecialtyUseCase
    implements UseCase<List<DoctorEntity>, GetDoctorsBySpecialtyParams> {
  final DoctorsRepository repository;

  const GetDoctorsBySpecialtyUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(
    GetDoctorsBySpecialtyParams params,
  ) {
    // تمرير الـ ID الجديد للـ repository
    return repository.getDoctorsBySpecialty(params.specialtyId);
  }
}

// إضافة الـ UseCase الخاص بجلب التخصصات والذي يستخدمه الـ Cubit
class GetSpecialtiesUseCase
    implements UseCase<List<SpecialtyEntity>, NoParams> {
  final DoctorsRepository repository;

  const GetSpecialtiesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SpecialtyEntity>>> call(NoParams params) {
    return repository.getSpecialties();
  }
}

class GetDoctorByUsernameParams {
  final String username;

  const GetDoctorByUsernameParams({required this.username});
}

class GetDoctorByUsernameUseCase
    implements UseCase<DoctorEntity, GetDoctorByUsernameParams> {
  final DoctorsRepository repository;

  const GetDoctorByUsernameUseCase(this.repository);

  @override
  Future<Either<Failure, DoctorEntity>> call(GetDoctorByUsernameParams params) {
    return repository.getDoctorByUsername(params.username);
  }
}
