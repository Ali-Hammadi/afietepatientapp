import 'package:dio/dio.dart';
import 'package:afietepatientapp/core/network/api_endpoints.dart';
import 'package:afietepatientapp/feature/doctors/data/models/doctor_model.dart';
import 'package:afietepatientapp/feature/doctors/domain/entites/doctor_entity.dart';

abstract class DoctorsRemoteDataSource {
  Future<List<DoctorModel>> getAllDoctors();
  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialty);
  Future<DoctorModel> getDoctorById(String id);
  Future<DoctorModel> getCurrentDoctorProfile();
  Future<DoctorScheduleModel> getDoctorScheduleById(String id);
  Future<DoctorModel> getDoctorPublicProfile(String username);
  Future<List<DoctorTimeSlot>> getDoctorAvailableSlots(
    String username,
    String date,
  );
}

class DoctorsRemoteDataSourceImpl implements DoctorsRemoteDataSource {
  final Dio _dio;

  DoctorsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final response = await _dio.get(ApiEndpoints.allDoctors);
      if (response.statusCode == 200) {
        final doctors = _parseDoctorList(response.data);
        return doctors;
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
        requestOptions: RequestOptions(path: ApiEndpoints.allDoctors),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialty) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.allDoctors,
        queryParameters: {'specialization': specialty},
      );
      if (response.statusCode == 200) {
        final doctors = _parseDoctorList(response.data);
        return doctors;
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
        requestOptions: RequestOptions(path: ApiEndpoints.allDoctors),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<DoctorModel> getDoctorById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.doctorById(id));
      if (response.statusCode == 200) {
        final data = _parseDoctorMap(response.data);
        final doctor = DoctorModel.fromJson(data);
        if (doctor.id.isEmpty) {
          throw _notFoundException(ApiEndpoints.doctorById(id));
        }
        return doctor;
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
        requestOptions: RequestOptions(path: ApiEndpoints.doctorById(id)),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<DoctorModel> getCurrentDoctorProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.doctorProfileUpdate);
      if (response.statusCode == 200) {
        final data = _parseDoctorMap(response.data);
        final doctor = DoctorModel.fromJson(data);
        if (doctor.id.isEmpty) {
          throw _notFoundException(ApiEndpoints.doctorProfileUpdate);
        }
        return doctor;
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
        requestOptions: RequestOptions(path: ApiEndpoints.doctorProfileUpdate),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<DoctorScheduleModel> getDoctorScheduleById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.doctorScheduleById(id));
      if (response.statusCode == 200) {
        final data = _parseScheduleMap(response.data);
        final schedule = DoctorScheduleModel.fromJson(data);
        if (schedule.id.isEmpty &&
            schedule.dayOfWeek.isEmpty &&
            schedule.startTime.isEmpty &&
            schedule.endTime.isEmpty) {
          throw _notFoundException(ApiEndpoints.doctorScheduleById(id));
        }
        return schedule;
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
          path: ApiEndpoints.doctorScheduleById(id),
        ),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  List<DoctorModel> _parseDoctorList(dynamic data) {
    final rawList = data is Map<String, dynamic>
        ? (data['doctors'] as List? ?? const [])
        : (data as List? ?? const []);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(DoctorModel.fromJson)
        .where((doctor) => doctor.id.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _parseDoctorMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw _notFoundException('doctor');
  }

  Map<String, dynamic> _parseScheduleMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw _notFoundException('schedule');
  }

  @override
  Future<DoctorModel> getDoctorPublicProfile(String username) async {
    final path = ApiEndpoints.doctorPublicProfile(username);
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        final data = _parseDoctorMap(response.data);
        final enriched = Map<String, dynamic>.from(data);
        final user = enriched['user'] as Map<String, dynamic>? ?? const {};
        if (!enriched.containsKey('id') || enriched['id'] == null) {
          final uname = user['username']?.toString();
          if (uname != null && uname.isNotEmpty) {
            enriched['id'] = uname;
          }
        }
        if (enriched.containsKey('photo') && !enriched.containsKey('imageUrl')) {
          enriched['imageUrl'] = enriched['photo'];
        }
        final doctor = DoctorModel.fromJson(enriched);
        return doctor;
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
        requestOptions: RequestOptions(path: path),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<List<DoctorTimeSlot>> getDoctorAvailableSlots(
    String username,
    String date,
  ) async {
    final path = ApiEndpoints.doctorAvailableSlots(username, date: date);
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200) {
        return _parseAvailableSlots(response.data);
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
        requestOptions: RequestOptions(path: path),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  List<DoctorTimeSlot> _parseAvailableSlots(dynamic data) {
    List<dynamic> rawList = const [];

    if (data is Map<String, dynamic>) {
      final raw =
          data['available_slots'] ?? data['slots'] ?? data['times'] ?? const [];
      if (raw is List) rawList = raw;
    } else if (data is List) {
      rawList = data;
    }

    final result = <DoctorTimeSlot>[];
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        final start = item['start']?.toString() ?? item['start_time']?.toString();
        final end = item['end']?.toString() ?? item['end_time']?.toString();
        if (start != null && end != null) {
          result.add(DoctorTimeSlot(start: start, end: end));
        }
      }
    }
    return result;
  }

  DioException _notFoundException(String path) {
    return DioException(
      requestOptions: RequestOptions(path: path),
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 404,
        data: const {'detail': 'No doctor found.'},
      ),
      type: DioExceptionType.badResponse,
    );
  }
}
