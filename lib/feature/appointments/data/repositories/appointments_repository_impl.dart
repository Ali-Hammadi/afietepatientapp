import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/appointments/data/datasources/appointments_remote_datasource.dart';
import 'package:afiete/feature/appointments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appointments/domain/repositories/appointments_repository.dart';
import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsRemoteDataSource dataSource;

  const AppointmentsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, AppointmentsData>> getAppointments() async {
    try {
      final result = await dataSource.getAppointments(); // ✅ يستدعي dataSource
      return Right<Failure, AppointmentsData>(result);
    } on DioException catch (e) {
      return Left<Failure, AppointmentsData>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, AppointmentsData>(
        ServerFailure('Unable to load appointments right now.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getAvailableSlots({
    required String doctorUsername,
    required String date,
  }) async {
    try {
      final result = await dataSource.getAvailableSlots(
        doctorUsername: doctorUsername,
        date: date,
      );
      return Right<Failure, List<dynamic>>(result);
    } on DioException catch (e) {
      return Left<Failure, List<dynamic>>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, List<dynamic>>(
          ServerFailure('Failed to load slots.'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> createAppointment({
    required dynamic appointmentId,
    required String doctorUsername,
    required String patientUsername,
    required String doctorName,
    required DateTime scheduledAt,
    required int durationSlots,
    required ConsultationFee consultationFee,
    required String sessionType,
  }) async {
    try {
      // ✅ احسب مدة الجلسة بالدقائق (كل slot = 30 دقيقة)
      final totalMinutes = durationSlots * 30;

      // ✅ التأكد من إن الوقت UTC قبل الإرسال
      final scheduledAtUtc =
          scheduledAt.isUtc ? scheduledAt : scheduledAt.toUtc();

      final result = await dataSource.createAppointment(
        slotStart:
            scheduledAtUtc.toIso8601String().split('T')[1].substring(0, 5),
        slotEnd: scheduledAtUtc
            .add(Duration(minutes: totalMinutes))
            .toIso8601String()
            .split('T')[1]
            .substring(0, 5),
        appointmentId: appointmentId,
        doctorUsername: doctorUsername,
        patientUsername: patientUsername,
        doctorName: doctorName,
        scheduledAt: scheduledAtUtc, // ✅ UTC
        durationSlots: durationSlots,
        consultationFee: consultationFee,
        sessionType: sessionType,
      );
      return Right<Failure, AppointmentEntity>(result);
    } on DioException catch (e) {
      return Left<Failure, AppointmentEntity>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, AppointmentEntity>(
        ServerFailure('Could not create booking draft. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelAppointment(dynamic appointmentId) async {
    try {
      await dataSource.cancelAppointment(appointmentId);
      return Right<Failure, void>(null);
    } on DioException catch (e) {
      return Left<Failure, void>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, void>(
          ServerFailure('Could not cancel appointment.'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> rescheduleAppointment({
    required int appointmentId,
    required String doctorUsername,
    required DateTime newDate,
    required String slotStart,
    required String slotEnd,
  }) async {
    try {
      final result = await dataSource.rescheduleAppointment(
        appointmentId: appointmentId,
        doctorUsername: doctorUsername,
        newDate: newDate,
        slotStart: slotStart,
        slotEnd: slotEnd,
      );
      return Right<Failure, AppointmentEntity>(result);
    } on DioException catch (e) {
      return Left<Failure, AppointmentEntity>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, AppointmentEntity>(
          ServerFailure('Could not reschedule appointment.'));
    }
  }
}
