import 'package:afiete/feature/appoinments/data/models/appointment_model.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';
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
  });

  Future<List<dynamic>> getAvailableSlots({
    required String doctorUsername,
    required String date,
  });

  Future<void> cancelAppointment(int appointmentId);

  Future<AppointmentModel> rescheduleAppointment({
    required int appointmentId,
    required DateTime newScheduledAt,
  });
}

class AppointmentsRemoteDataSourceImpl implements AppointmentsRemoteDataSource {
  final Dio _dio;

  AppointmentsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final response = await _dio.get(ApiEndpoints.myAppointments);
      if (response.statusCode == 200) {
        final body = response.data;
        if (body is List) {
          return body
              .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (body is Map<String, dynamic> &&
            body['appointments'] is List) {
          final list = body['appointments'] as List;
          return list
              .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
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
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createAppointment,
        data: {
          'appointment_id': appointmentId,
          'doctor_username': doctorUsername,
          'patient_username': patientUsername,
          'doctor_name': doctorName,
          'date': scheduledAt.toIso8601String(),
          'duration_slots': durationSlots,
          'session_type': sessionType,
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
  Future<List<dynamic>> getAvailableSlots(
      {required String doctorUsername, required String date}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.doctorAvailableSlots(doctorUsername),
        queryParameters: {'doctor_username': doctorUsername, 'date': date},
      );
      if (response.statusCode == 200) {
        final body = response.data;
        if (body is List) return body;
        if (body is Map<String, dynamic> && body['slots'] is List) {
          return body['slots'] as List;
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
      await _dio.post(ApiEndpoints.cancelAppointment(appointmentId.toString()));
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
    required DateTime newScheduledAt,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.reschedualAppointment(appointmentId.toString()),
        data: {
          'appointmentId': appointmentId,
          'newScheduledAt': newScheduledAt.toIso8601String(),
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
}
