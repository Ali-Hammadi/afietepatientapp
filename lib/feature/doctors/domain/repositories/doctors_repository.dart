import 'package:afiete/feature/doctors/domain/entities/speciality_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';

abstract class DoctorsRepository {
  Future<Either<Failure, List<DoctorEntity>>> getAllDoctors();
  Future<Either<Failure, List<String>>> getAllSpecialties();
  Future<Either<Failure, List<DoctorEntity>>> getDoctorsBySpecialty(
    int specialtyId,
  );
  Future<Either<Failure, List<SpecialtyEntity>>> getSpecialties();
  Future<Either<Failure, DoctorEntity>> getDoctorByUsername(String username);
  Future<Either<Failure, DoctorEntity>> getCurrentDoctorProfile();
  Future<Either<Failure, DoctorSchedule>> getDoctorScheduleById(String id);
  Future<Either<Failure, DoctorEntity>> getDoctorPublicProfile(
    String username,
  );
  Future<Either<Failure, List<DoctorTimeSlot>>> getDoctorAvailableSlots(
    String username,
    String date,
  );
}
