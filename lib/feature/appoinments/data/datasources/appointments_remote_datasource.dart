import 'package:afiete/feature/appoinments/data/models/appointment_model.dart';
import 'package:afiete/feature/appoinments/domain/values/consultation_fee.dart';
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

abstract class AppointmentsRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments();

  Future<AppointmentModel> createAppointment({
    required String doctorUsername,
    required String patientUsername,
    required String doctorName,
    required DateTime scheduledAt,
    required int durationSlots,
    required ConsultationFee consultationFee,
    required String sessionType,
  });

  Future<void> cancelAppointment(String appointmentId);

  Future<AppointmentModel> rescheduleAppointment({
    required String appointmentId,
    required DateTime newScheduledAt,
  });
}

class AppointmentsRemoteDataSourceImpl implements AppointmentsRemoteDataSource {
  final Dio _dio;

  AppointmentsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      // استخدام الاندبوينت الجديد الخاص بـ Django
      final response = await _dio.get(ApiEndpoints.myAppointments);

      if (response.statusCode == 200) {
        final body = response.data;
        List<dynamic> data = const [];

        // الـ Django يرجع الـ List مباشرة [ {} , {} ]
        if (body is List) {
          data = body;
        } else if (body is Map<String, dynamic>) {
          final dynamic fromAppointments = body['appointments'];
          final dynamic fromData = body['data'];

          if (fromAppointments is List) {
            data = fromAppointments;
          } else if (fromData is List) {
            data = fromData;
          }
        }

        return data
            .map(
                (apt) => AppointmentModel.fromJson(apt as Map<String, dynamic>))
            .toList();
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
        requestOptions: RequestOptions(path: ApiEndpoints.myAppointments),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<AppointmentModel> createAppointment({
    required String doctorUsername,
    required String patientUsername,
    required String doctorName,
    required DateTime scheduledAt,
    required int durationSlots,
    required ConsultationFee consultationFee,
    required String sessionType,
  }) async {
    try {
      // حساب وقت النهاية بناءً على السلوتات (كل سلوت 30 دقيقة كما في الـ Entity)
      final endAt = scheduledAt.add(Duration(minutes: durationSlots * 30));

      // تشكيل الـ Payload المطلوب تماماً من الـ Django
      final Map<String, dynamic> djangoPayload = {
        "doctor_username":
            doctorUsername, // الـ Django يتوقع الـ doctorUsername هنا
        "type": sessionType, // مثل 'video'
        "day_date":
            "${scheduledAt.year}-${scheduledAt.month.toString().padLeft(2, '0')}-${scheduledAt.day.toString().padLeft(2, '0')}",
        "slot": {
          "start": scheduledAt.toIso8601String(),
          "end": endAt.toIso8601String()
        }
      };

      final response = await _dio.post(
        ApiEndpoints.createAppointment,
        data: djangoPayload,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      // إرسال طلب الـ POST للرابط الديناميكي المضاف في الـ Endpoints
      final response = await _dio.post(
        ApiEndpoints.cancelAppointment(appointmentId),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: ApiEndpoints.cancelAppointment(appointmentId),
        ),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<AppointmentModel> rescheduleAppointment({
    required String appointmentId,
    required DateTime newScheduledAt,
  }) async {
    // إذا كان الـ Django يدعم الـ Reschedule فقم بتركيب الاندبوينت الخاص به هنا بنفس الطريقة،
    // أو اتركه كما هو حالياً مستهدفاً الـ Legacy لحين توفير الاندبوينت من الباك-إند.
    try {
      final response = await _dio.post(
        ApiEndpoints.appointmentsReschedule,
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
        requestOptions:
            RequestOptions(path: ApiEndpoints.appointmentsReschedule),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }
}
