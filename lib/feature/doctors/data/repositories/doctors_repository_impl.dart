import 'package:afiete/feature/doctors/domain/entities/speciality_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/doctors/data/datasources/doctors_remote_datasource.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/repositories/doctors_repository.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  final DoctorsRemoteDataSource remoteDataSource;

  const DoctorsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DoctorEntity>>> getAllDoctors() async {
    try {
      final doctors = await remoteDataSource.getAllDoctors();
      return Right(doctors);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 500) {
        return const Right(<DoctorEntity>[]);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllSpecialties() async {
    try {
      final specialties = await remoteDataSource.getAllSpecialties();
      return Right(specialties);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // تصحيح: تغيير المعامل ليكون متوافقاً مع الـ interface (int specialtyId)
  @override
  Future<Either<Failure, List<DoctorEntity>>> getDoctorsBySpecialty(
    int specialtyId,
  ) async {
    try {
      // استدعاء الدالة المحدثة في الـ DataSource وتمرير الرقم المباشر
      final doctors = await remoteDataSource.getDoctorsBySpecialty(specialtyId);
      return Right(doctors);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SpecialtyEntity>>> getSpecialties() async {
    try {
      final specialties = await remoteDataSource.getSpecialties();
      return Right(specialties);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorEntity>> getDoctorByUsername(
      String username) async {
    try {
      final doctor = await remoteDataSource.getDoctorPublicProfile(username);
      return Right(doctor);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorEntity>> getCurrentDoctorProfile() async {
    return Left(
        ServerFailure('getCurrentDoctorProfile غير متوفرة في تطبيق المريض.'));
  }

  @override
  Future<Either<Failure, DoctorSchedule>> getDoctorScheduleById(
      String id) async {
    return Left(ServerFailure(
        'getDoctorScheduleById غير مدعومة، يرجى الاعتماد على جلب الفترات المتاحة للـ username.'));
  }

  @override
  Future<Either<Failure, DoctorEntity>> getDoctorPublicProfile(
      String username) async {
    try {
      final doctor = await remoteDataSource.getDoctorPublicProfile(username);
      return Right(doctor);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DoctorTimeSlot>>> getDoctorAvailableSlots(
      String username, String date) async {
    try {
      final slots =
          await remoteDataSource.getDoctorAvailableSlots(username, date);
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
