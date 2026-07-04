import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/appointments/data/datasources/appointments_remote_datasource.dart';
import 'package:afiete/feature/appointments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class AppointmentsRepository {
  final AppointmentsRemoteDataSource dataSource;
  const AppointmentsRepository({required this.dataSource});
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

  Future<Either<Failure, List<dynamic>>> getAvailableSlots({
    required String doctorUsername,
    required String date,
  });

  Future<Either<Failure, AppointmentEntity>> createAppointment({
    required dynamic appointmentId,
    required String doctorUsername,
    required String patientUsername,
    required String doctorName,
    required DateTime scheduledAt,
    required int durationSlots,
    required ConsultationFee consultationFee,
    required String sessionType,
  });

  Future<Either<Failure, void>> cancelAppointment(dynamic appointmentId);

  Future<Either<Failure, AppointmentEntity>> rescheduleAppointment({
    required int appointmentId,
    required String doctorUsername,
    required DateTime newDate,
    required String slotStart,
    required String slotEnd,
  });
}
