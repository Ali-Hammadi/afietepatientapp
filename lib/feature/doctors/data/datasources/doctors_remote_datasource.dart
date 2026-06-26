import 'package:dio/dio.dart';
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/doctors/data/models/doctor_model.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/entities/speciality_entity.dart';

abstract class DoctorsRemoteDataSource {
  Future<List<DoctorModel>> getAllDoctors();
  Future<List<DoctorModel>> getRecommendedDoctors();
  Future<List<DoctorModel>> getDoctorsBySpecialty(int specialtyId);
  Future<List<SpecialtyEntity>> getSpecialties();
  Future<List<String>> getAllSpecialties();
  Future<DoctorModel> getDoctorByUsername(String username);
  Future<DoctorModel> getDoctorPublicProfile(String username);
  Future<List<DoctorTimeSlot>> getDoctorAvailableSlots(
      String username, String? date);
}

class DoctorsRemoteDataSourceImpl implements DoctorsRemoteDataSource {
  final Dio _dio;

  DoctorsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final response = await _dio.get(ApiEndpoints.allDoctors);
      if (response.statusCode == 200) {
        return _parseDoctorList(response.data);
      }
      throw _badResponseException(response);
    } on DioException {
      rethrow;
    } catch (e) {
      throw _unknownException(ApiEndpoints.allDoctors, e);
    }
  }

  @override
  Future<List<DoctorModel>> getRecommendedDoctors() async {
    try {
      final response = await _dio.get(ApiEndpoints.recommendedDoctors);
      if (response.statusCode == 200) {
        return _parseDoctorList(response.data);
      }
      throw _badResponseException(response);
    } on DioException {
      rethrow;
    } catch (e) {
      throw _unknownException(ApiEndpoints.recommendedDoctors, e);
    }
  }

  @override
  Future<List<DoctorModel>> getDoctorsBySpecialty(int specialtyId) async {
    try {
      // إرسال الـ ID كـ query parameter وهو الأسلوب الافتراضي في Django لفلترة الـ ForeignKeys
      final response = await _dio.get(
        ApiEndpoints.allDoctors,
        queryParameters: {'specialty': specialtyId},
      );
      if (response.statusCode == 200) {
        return _parseDoctorList(response.data);
      }
      throw _badResponseException(response);
    } on DioException {
      rethrow;
    } catch (e) {
      throw _unknownException(ApiEndpoints.allDoctors, e);
    }
  }

  @override
  Future<List<SpecialtyEntity>> getSpecialties() async {
    try {
      // استبدل الرابط بالـ endpoint الفعلي للتخصصات في الـ ApiEndpoints لديك
      final response = await _dio.get(ApiEndpoints.allSpecialties);
      if (response.statusCode == 200) {
        final List<dynamic> rawList = response.data is Map
            ? response.data['results'] ?? response.data
            : response.data;
        return rawList
            .map((json) =>
                SpecialtyEntity.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw _badResponseException(response);
    } on DioException {
      rethrow;
    } catch (e) {
      throw _unknownException('getSpecialties', e);
    }
  }

  @override
  Future<List<String>> getAllSpecialties() async {
    // ترك دالة النصوص القديمة فارغة أو جلبها لضمان عدم كسر أي جزء آخر مؤقتاً
    return const [];
  }

  @override
  Future<DoctorModel> getDoctorByUsername(String username) async {
    final path = ApiEndpoints.doctorByUsername(username);
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return DoctorModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw _badResponseException(response);
    } on DioException {
      rethrow;
    } catch (e) {
      throw _unknownException(path, e);
    }
  }

  @override
  Future<DoctorModel> getDoctorPublicProfile(String username) async {
    final path = ApiEndpoints.doctorPublicProfile(username);
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return DoctorModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw _badResponseException(response);
    } on DioException {
      rethrow;
    } catch (e) {
      throw _unknownException(path, e);
    }
  }

  @override
  Future<List<DoctorTimeSlot>> getDoctorAvailableSlots(
    String username,
    String? date,
  ) async {
    final path = ApiEndpoints.doctorAvailableSlots(username);

    try {
      final response = await _dio.get(
        path,
        queryParameters: {
          'date': date,
        },
      );

      if (response.statusCode == 200) {
        return _parseAvailableSlots(response.data);
      }

      throw _badResponseException(response);
    } on DioException {
      rethrow;
    } catch (e) {
      throw _unknownException(path, e);
    }
  }

  List<DoctorModel> _parseDoctorList(dynamic data) {
    List<dynamic> rawList = const [];
    if (data is Map<String, dynamic>) {
      final raw =
          data['doctors'] ?? data['results'] ?? data['data'] ?? const [];
      if (raw is List) rawList = raw;
    } else if (data is List) {
      rawList = data;
    }
    return rawList
        .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<DoctorTimeSlot> _parseAvailableSlots(dynamic data) {
    print("[Available Slots Debug] >>> البيانات القادمة: $data");

    List<dynamic> rawList = const [];

    // تعديل: الفحص باستخدام Map بدلاً من Map<String, dynamic> لتجنب مشاكل الكاستينغ الداخلي
    if (data is Map) {
      final raw = data['available_slots'] ??
          data['slots'] ??
          data['times'] ??
          data['results'] ??
          const [];
      if (raw is List) rawList = raw;
    } else if (data is List) {
      rawList = data;
    }

    final result = <DoctorTimeSlot>[];
    for (final item in rawList) {
      // الحالة الأولى: إذا كان الباك-أند يرسل الأوقات كنصوص مباشرة مثل ["08:00", "08:30"]
      if (item is String) {
        result.add(DoctorTimeSlot(start: item, end: item));
      } else if (item is Map) {
        final start = item['start']?.toString() ??
            item['start_time']?.toString() ??
            item['time']?.toString();

        final end =
            item['end']?.toString() ?? item['end_time']?.toString() ?? start;

        if (start != null) {
          result.add(DoctorTimeSlot(start: start, end: end!));
        }
      }
    }
    return result;
  }

  DioException _badResponseException(Response response) {
    return DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  DioException _unknownException(String path, dynamic error) {
    return DioException(
      requestOptions: RequestOptions(path: path),
      error: error,
      type: DioExceptionType.unknown,
    );
  }
}
