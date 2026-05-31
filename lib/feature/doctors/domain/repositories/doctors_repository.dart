import 'package:dartz/dartz.dart';
import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/feature/doctors/domain/entites/doctor_entity.dart';

abstract class DoctorsRepository {
  Future<Either<Failure, List<DoctorEntity>>> getAllDoctors();
  Future<Either<Failure, List<DoctorEntity>>> getDoctorsBySpecialty(
    String specialty,
  );
  Future<Either<Failure, DoctorEntity>> getDoctorById(String id);
  Future<Either<Failure, DoctorEntity>> getCurrentDoctorProfile();
  Future<Either<Failure, DoctorSchedule>> getDoctorScheduleById(String id);
}
