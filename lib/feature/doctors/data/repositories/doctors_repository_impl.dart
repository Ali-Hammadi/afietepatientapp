import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/feature/doctors/data/datasources/doctors_remote_datasource.dart';
import 'package:afietepatientapp/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afietepatientapp/feature/doctors/domain/repositories/doctors_repository.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  final DoctorsRemoteDataSource remoteDataSource;

  const DoctorsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DoctorEntity>>> getAllDoctors() async {
    try {
      final doctors = await remoteDataSource.getAllDoctors();
      return Right(doctors.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right(<DoctorEntity>[]);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DoctorEntity>>> getDoctorsBySpecialty(
    String specialty,
  ) async {
    try {
      final doctors = await remoteDataSource.getDoctorsBySpecialty(specialty);
      return Right(doctors.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right(<DoctorEntity>[]);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorEntity>> getDoctorById(String id) async {
    try {
      final doctor = await remoteDataSource.getDoctorById(id);
      return Right(doctor.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorEntity>> getCurrentDoctorProfile() async {
    try {
      final doctor = await remoteDataSource.getCurrentDoctorProfile();
      return Right(doctor.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorSchedule>> getDoctorScheduleById(
    String id,
  ) async {
    try {
      final schedule = await remoteDataSource.getDoctorScheduleById(id);
      return Right(schedule.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorEntity>> getDoctorPublicProfile(
    String username,
  ) async {
    try {
      final doctor = await remoteDataSource.getDoctorPublicProfile(username);
      return Right(doctor.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DoctorTimeSlot>>> getDoctorAvailableSlots(
    String username,
    String date,
  ) async {
    try {
      final slots = await remoteDataSource.getDoctorAvailableSlots(
        username,
        date,
      );
      return Right(slots);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right(<DoctorTimeSlot>[]);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
