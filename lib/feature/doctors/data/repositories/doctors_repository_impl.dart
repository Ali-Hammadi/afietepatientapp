import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/doctors/data/datasources/doctors_remote_datasource.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/repositories/doctors_repository.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  final DoctorsRemoteDataSource remoteDataSource;

  const DoctorsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DoctorEntity>>> getAllDoctors() async {
    try {
      final doctors = await remoteDataSource.getAllDoctors();
      return Right(doctors.map((model) => model).toList());
    } on DioException catch (e) {
      // 404 = endpoint not found / no assessment yet; 500 = server error before
      // assessment data is available — both map to an empty list, not an error.
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
  Future<Either<Failure, List<DoctorEntity>>> getDoctorsBySpecialty(
    String specialty,
  ) async {
    try {
      final doctors = await remoteDataSource.getDoctorsBySpecialty(specialty);
      // تم إزالة .toEntity() لأن DoctorModel هو بالأساس DoctorEntity
      return Right(doctors.map((model) => model).toList());
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
  Future<Either<Failure, DoctorEntity>> getDoctorByUsername(
      String username) async {
    try {
      // تم تصحيح الميثود واستخدام getDoctorPublicProfile لأن الـ id هنا يُمثّل الـ username للباك-أند
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
    // هندلة الدالة لتعيد خطأ مخصص لأن المريض لا يملك بروفايل طبيب في تطبيق المريض الحالي
    return Left(
        ServerFailure('getCurrentDoctorProfile غير متوفرة في تطبيق المريض.'));
  }

  @override
  Future<Either<Failure, DoctorSchedule>> getDoctorScheduleById(
    String id,
  ) async {
    // هندلة الدالة لإرجاع خطأ مخصص، نظراً للاعتماد الكلي على حجز الفترات عبر جلب المواعيد المتاحة (Slots)
    return Left(ServerFailure(
        'getDoctorScheduleById غير مدعومة، يرجى الاعتماد على جلب الفترات المتاحة للـ username.'));
  }

  @override
  Future<Either<Failure, DoctorEntity>> getDoctorPublicProfile(
    String username,
  ) async {
    try {
      final doctor = await remoteDataSource.getDoctorPublicProfile(username);
      // تم إزالة .toEntity() هنا أيضاً ليتوافق الكود
      return Right(doctor);
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
