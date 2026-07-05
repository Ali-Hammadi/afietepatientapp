import 'package:afiete/feature/appointments/data/models/appointment_model.dart';
import 'package:afiete/feature/appointments/domain/values/consultation_fee.dart';
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

// ✅ كلاس جديد لحفظ 3 قوائم منفصلة
class AppointmentsData {
  final List<AppointmentModel> upcoming;
  final List<AppointmentModel> past;
  final List<AppointmentModel> missed;
  final List<AppointmentModel> canceled; // ✅ جديد

  AppointmentsData({
    required this.upcoming,
    required this.past,
    required this.missed,
    required this.canceled, // ✅ جديد
  });

  // ✅ دالة مساعدة للحصول على كل المواعيد (للتوافق مع الكود الحالي)
  List<AppointmentModel> get allAppointments => [
        ...upcoming,
        ...past,
        ...missed,
        ...canceled, // ✅ جديد
      ];

  List<AppointmentModel> get appointments => allAppointments;
}

abstract class AppointmentsRemoteDataSource {
  Future<AppointmentsData> getAppointments(); // ✅ تغيير نوع الإرجاع

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

// ✅ في دالة getAppointments() - استبدل الفلترة القديمة بهاد:

  @override
  Future<AppointmentsData> getAppointments() async {
    try {
      // ✅ جلب 4 endpoints بالتوازي
      final responses = await Future.wait([
        _dio.get(ApiEndpoints.upcomingAppointments),
        _dio.get(ApiEndpoints.pastAppointments),
        _dio.get(ApiEndpoints.missedAppointments),
        _dio.get(ApiEndpoints.canceledAppointments),
      ].map((future) => future.catchError((_) => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
          ))));

      // ✅ دالة مساعدة لتحويل الاستجابة إلى قائمة AppointmentModel
      List<AppointmentModel> parseResponse(Response response) {
        if (response.statusCode != 200) return [];

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

        return list
            .map((json) =>
                AppointmentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      final myAppointments = parseResponse(responses[0]);
      final historyAppointments = parseResponse(responses[1]);
      final missedAppointments = parseResponse(responses[2]);
      final canceled = parseResponse(responses[3]);

      // ✅ جمع IDs المواعيد الملغاة (من endpoint canceled)
      final canceledIds = canceled.map((appt) => appt.appointmentId).toSet();

      // ✅ إضافة IDs المواعيد التي حالتها cancelled (من أي endpoint)
      for (final appt in historyAppointments) {
        final status = appt.status.toLowerCase();
        if (status == 'cancelled' || status == 'canceled') {
          canceledIds.add(appt.appointmentId);
        }
      }

      // ✅ فلترة دقيقة بناءً على الوقت الحالي
      final now = DateTime.now().toUtc();

      final upcoming = <AppointmentModel>[];
      final past = <AppointmentModel>[];

      // ✅ فلترة myAppointments - القادمة فقط (ما اجا وقتها)
      for (final appointment in myAppointments) {
        final appointmentTime = appointment.scheduledAt.toUtc();

        // ✅ تجاهل المواعيد الملغاة من upcoming
        final status = appointment.status.toLowerCase();
        if (status == 'cancelled' || status == 'canceled') {
          continue; // ✅ لا تضاف لـ upcoming
        }

        if (appointmentTime.isAfter(now)) {
          // ✅ الجلسة قادمة (لم يحن وقتها بعد)
          upcoming.add(appointment);
        } else {
          // ✅ الجلسة انتهت وقتها - تعتبر past
          past.add(appointment);
        }
      }

      // ✅ إضافة المواعيد من history - لكن نفلتر الـ canceled منها
      final historyFiltered = historyAppointments.where((appt) {
        // ✅ تجاهل إذا كان ضمن قائمة canceled
        if (canceledIds.contains(appt.appointmentId)) {
          return false;
        }

        final status = appt.status.toLowerCase();
        // ✅ تجاهل الـ canceled
        if (status == 'cancelled' || status == 'canceled') {
          return false;
        }

        return true;
      }).toList();

      past.addAll(historyFiltered);

      // ✅ جلسات missed منفصلة
      final missed = missedAppointments;

      return AppointmentsData(
        upcoming: upcoming,
        past: past,
        missed: missed,
        canceled: canceled,
      );
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: 'appointments'),
        error: e,
      );
    }
  }

  // ✅ باقي الدوال كما هي بدون تغيير
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
        List<dynamic> allSlots = [];

        if (body is List) {
          allSlots = body;
        } else if (body is Map<String, dynamic>) {
          // ✅ دمج الأوقات المتاحة والمحجوزة
          final available = body['available_slots'] as List? ?? [];
          final booked = body['booked_slots'] as List? ?? [];
          final unavailable = body['unavailable_slots'] as List? ?? [];

          // ✅ إضافة status لكل slot
          allSlots = [
            ...available.map((slot) => {
                  ...slot as Map<String, dynamic>,
                  'status': 'available',
                  'is_booked': false,
                }),
            ...booked.map((slot) => {
                  ...slot as Map<String, dynamic>,
                  'status': 'booked',
                  'is_booked': true,
                }),
            ...unavailable.map((slot) => {
                  ...slot as Map<String, dynamic>,
                  'status': 'unavailable',
                  'is_booked': false,
                }),
          ];
        }

        return allSlots;
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
