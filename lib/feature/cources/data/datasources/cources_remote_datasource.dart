// lib/feature/courses/data/datasources/courses_remote_datasource.dart
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/cources/data/models/cources_model.dart';
import 'package:dio/dio.dart';

abstract class CoursesRemoteDataSource {
  Future<CourseModel?> getActiveCourse();
  Future<List<CourseModel>> getArchivedCourses();
  Future<void> endCourse(int courseId);
  Future<void> requestContinue(int courseId);
  Future<void> declineContinue(int courseId);
}

class CoursesRemoteDataSourceImpl implements CoursesRemoteDataSource {
  final Dio _dio;
  CoursesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  // ✅ دالة مساعدة للـ retry
  Future<T> _retryRequest<T>(Future<T> Function() request,
      {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        return await request();
      } on DioException catch (e) {
        // ✅ إذا كان connection error، جرب مرة ثانية
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.unknown) {
          print('⚠️ Attempt $attempt failed, retrying...');
          if (attempt == maxRetries) {
            rethrow;
          }
          await Future.delayed(Duration(seconds: attempt)); // ✅ تأخير متزايد
        } else {
          rethrow;
        }
      }
    }
    throw Exception('Max retries exceeded');
  }

  @override
  Future<CourseModel?> getActiveCourse() async {
    return _retryRequest(() async {
      try {
        final response = await _dio.get(ApiEndpoints.patientActiveCourse);
        if (response.statusCode == 200 && response.data != null) {
          return CourseModel.fromJson(response.data as Map<String, dynamic>);
        }
        return null;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) return null;
        rethrow;
      }
    });
  }

  @override
  Future<List<CourseModel>> getArchivedCourses() async {
    return _retryRequest(() async {
      try {
        final response = await _dio.get(ApiEndpoints.patientArchivedCourses);
        if (response.statusCode == 200) {
          final data = response.data;
          List<dynamic> list = [];

          if (data is List) {
            list = data;
          } else if (data is Map<String, dynamic> && data['results'] is List) {
            list = data['results'] as List;
          }

          return list
              .map((json) => CourseModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      } on DioException {
        rethrow;
      }
    });
  }

  @override
  Future<void> endCourse(int courseId) async {
    return _retryRequest(() async {
      // ✅ تغيير PUT إلى PATCH
      await _dio.patch(ApiEndpoints.patientEndCourse(courseId));
    });
  }

  @override
  Future<void> requestContinue(int courseId) async {
    return _retryRequest(() async {
      await _dio.post(ApiEndpoints.patientRequestContinue(courseId));
    });
  }

  @override
  Future<void> declineContinue(int courseId) async {
    return _retryRequest(() async {
      await _dio.post(ApiEndpoints.patientDeclineContinue(courseId));
    });
  }
}
