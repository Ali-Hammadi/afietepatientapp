// lib/feature/courses/data/repositories/course_repository.dart
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class CourseRepository {
  final Dio _dio;

  CourseRepository(this._dio);

  Future<bool> requestContinue(int courseId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.patientRequestContinue(courseId),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> declineContinue(int courseId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.patientDeclineContinue(courseId),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> endCourse(int courseId) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.patientEndCourse(courseId),
        data: {'status': 'completed'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
