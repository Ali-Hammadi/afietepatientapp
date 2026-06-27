import 'package:afiete/feature/appointments/data/models/appointment_model.dart';
import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

abstract class AppointmentsRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments();

  Future<AppointmentModel> createAppointment({
    required int appointmentId,
    required String doctorUsername,
    required String patientUsername,
    required String doctorName,
    required DateTime scheduledAt,
    required int durationSlots,
    required ConsultationFee consultationFee,
    required String sessionType,
    required String slotStart,
    required String slotEnd,
  });

  Future<List<dynamic>> getAvailableSlots({
    required String doctorUsername,
    required String date,
  });

  Future<void> cancelAppointment(int appointmentId);

  Future<AppointmentModel> rescheduleAppointment({
    required int appointmentId,
    required String doctorUsername,
    required DateTime newDate,
    required String slotStart,
    required String slotEnd,
  });

  Future<void> updateNextSession({
    required int appointmentId,
    required bool hasNextSession,
  });
}

class AppointmentsRemoteDataSourceImpl implements AppointmentsRemoteDataSource {
  final Dio _dio;

  AppointmentsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final responses = await Future.wait([
        _dio.get(ApiEndpoints.myAppointments),
        _dio.get(ApiEndpoints.historyAppointments),
        _dio.get(ApiEndpoints.missedAppointments),
      ].map((future) => future.catchError((_) => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ))));

      final List<AppointmentModel> allAppointments = [];

      for (var response in responses) {
        if (response.statusCode == 200) {
          final data = response.data;
          List<dynamic> list = [];

          if (data is List) {
            list = data;
          } else if (data is Map<String, dynamic> && data['results'] is List) {
            list = data['results'] as List;
          } else if (data is Map<String, dynamic> &&
              data['appointments'] is List) {
            list = data['appointments'] as List;
          }

          allAppointments.addAll(
            list
                .map((json) =>
                    AppointmentModel.fromJson(json as Map<String, dynamic>))
                .toList(),
          );
        }
      }
      return allAppointments;
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.myAppointments),
        error: e,
      );
    }
  }

  @override
  Future<AppointmentModel> createAppointment({
    required int appointmentId,
    required String doctorUsername,
    required String patientUsername,
    required String doctorName,
    required DateTime scheduledAt,
    required int durationSlots,
    required ConsultationFee consultationFee,
    required String sessionType,
    required String slotStart,
    required String slotEnd,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createAppointment,
        data: {
          'doctor_username': doctorUsername,
          'type': sessionType,
          'day_date': scheduledAt.toIso8601String().split('T')[0],
          'slot': {
            'start': slotStart,
            'end': slotEnd,
          },
          'appointment_id': appointmentId,
          'patient_username': patientUsername,
          'doctor_name': doctorName,
          'duration_slots': durationSlots,
          'consultation_fee': {
            'textChat': consultationFee.textChat,
            'videoCall': consultationFee.videoCall,
            'voiceCall': consultationFee.voiceCall,
          },
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          final nested = body['appointment'];
          if (nested is Map<String, dynamic>) {
            return AppointmentModel.fromJson(nested);
          }
          return AppointmentModel.fromJson(body);
        }
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.createAppointment),
        error: e,
      );
    }
  }

  @override
  Future<List<dynamic>> getAvailableSlots({
    required String doctorUsername,
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.doctorAvailableSlots(doctorUsername),
        queryParameters: {'date': date},
      );
      if (response.statusCode == 200) {
        final body = response.data;
        if (body is List) return body;
        if (body is Map<String, dynamic> && body['available_slots'] is List) {
          return body['available_slots'] as List;
        }
      }
      return [];
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
            path: ApiEndpoints.doctorAvailableSlots(doctorUsername)),
        error: e,
      );
    }
  }

  @override
  Future<void> cancelAppointment(int appointmentId) async {
    try {
      await _dio
          .patch(ApiEndpoints.cancelAppointment(appointmentId.toString()));
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
            path: ApiEndpoints.cancelAppointment(appointmentId.toString())),
        error: e,
      );
    }
  }

  @override
  Future<AppointmentModel> rescheduleAppointment({
    required int appointmentId,
    required String doctorUsername,
    required DateTime newDate,
    required String slotStart,
    required String slotEnd,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.reschedualAppointment(appointmentId.toString()),
        data: {
          'doctor_username': doctorUsername,
          'day_date': newDate.toIso8601String().split('T')[0],
          'slot': {
            'start': slotStart,
            'end': slotEnd,
          },
        },
      );
      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map<String, dynamic>) {
          final nested = body['appointment'];
          if (nested is Map<String, dynamic>) {
            return AppointmentModel.fromJson(nested);
          }
          return AppointmentModel.fromJson(body);
        }
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
            path: ApiEndpoints.reschedualAppointment(appointmentId.toString())),
        error: e,
      );
    }
  }

  @override
  Future<void> updateNextSession({
    required int appointmentId,
    required bool hasNextSession,
  }) async {
    try {
      // نستخدم الاند بوينت الصحيح من ملفك
      await _dio.patch(
        ApiEndpoints.hasNextAppointment(appointmentId.toString()),
        data: {'has_next_session': hasNextSession},
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
            path: ApiEndpoints.hasNextAppointment(appointmentId.toString())),
        error: e,
      );
    }
  }
}
