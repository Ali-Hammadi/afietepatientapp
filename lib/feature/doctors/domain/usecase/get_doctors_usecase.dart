import 'package:dartz/dartz.dart';
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/repositories/doctors_repository.dart';

class GetAllDoctorsUseCase implements UseCase<List<DoctorEntity>, NoParams> {
  final DoctorsRepository repository;

  const GetAllDoctorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(NoParams params) {
    return repository.getAllDoctors();
  }
}

class GetDoctorsBySpecialtyParams {
  final String specialty;

  const GetDoctorsBySpecialtyParams({required this.specialty});
}

class GetDoctorsBySpecialtyUseCase
    implements UseCase<List<DoctorEntity>, GetDoctorsBySpecialtyParams> {
  final DoctorsRepository repository;

  const GetDoctorsBySpecialtyUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(
    GetDoctorsBySpecialtyParams params,
  ) {
    return repository.getDoctorsBySpecialty(params.specialty);
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
