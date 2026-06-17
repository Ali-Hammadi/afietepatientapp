import 'package:afiete/feature/sessions/data/models/review_model.dart';
import 'package:afiete/feature/sessions/data/models/session_model.dart';
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

abstract class SessionsRemoteDataSource {
  Future<List<SessionModel>> getUpcomingSessions();

  Future<List<SessionModel>> getPastSessions();

  Future<SessionModel> joinSession(String sessionId);

  Future<void> cancelSession({
    required String sessionId,
    required String username,
  });

  Future<SessionModel> rescheduleSession({
    required String sessionId,
    required DateTime newScheduledAt,
  });

  Future<ReviewModel> addReview({
    required String sessionId,
    required int rating,
    required String comment,
  });
}

class SessionsRemoteDataSourceImpl implements SessionsRemoteDataSource {
  final Dio _dio;

  SessionsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<SessionModel>> getUpcomingSessions() async {
    try {
      final response = await _dio.get(ApiEndpoints.myAppointments);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['sessions'] ?? [];
        return data
            .map(
              (session) =>
                  SessionModel.fromJson(session as Map<String, dynamic>),
            )
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
  Future<List<SessionModel>> getPastSessions() async {
    try {
      final response = await _dio.get(ApiEndpoints.historyAppointments);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['sessions'] ?? [];
        return data
            .map(
              (session) =>
                  SessionModel.fromJson(session as Map<String, dynamic>),
            )
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
        requestOptions: RequestOptions(path: ApiEndpoints.historyAppointments),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  /// Here will update later to add Sessions conversation type
  @override
  Future<SessionModel> joinSession(String sessionId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.myAppointment(sessionId),
        data: {'sessionId': sessionId},
      );
      if (response.statusCode == 200) {
        return SessionModel.fromJson(response.data as Map<String, dynamic>);
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
            RequestOptions(path: ApiEndpoints.myAppointment(sessionId)),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> cancelSession({
    required String sessionId,
    required String username,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.cancelAppointment(sessionId),
        data: {'sessionId': sessionId, 'username': username},
      );
      if (response.statusCode != 200) {
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
        requestOptions:
            RequestOptions(path: ApiEndpoints.cancelAppointment(sessionId)),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<SessionModel> rescheduleSession({
    required String sessionId,
    required DateTime newScheduledAt,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.reschedualAppointment(sessionId),
        data: {
          'sessionId': sessionId,
          'newScheduledAt': newScheduledAt.toIso8601String(),
        },
      );
      if (response.statusCode == 200) {
        return SessionModel.fromJson(response.data as Map<String, dynamic>);
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
          path: ApiEndpoints.reschedualAppointment(sessionId),
        ),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }

  @override
  Future<ReviewModel> addReview({
    required String sessionId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.rateAppointment(sessionId),
        data: {'sessionId': sessionId, 'rating': rating, 'comment': comment},
      );
      if (response.statusCode == 201) {
        return ReviewModel.fromJson(response.data as Map<String, dynamic>);
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
            RequestOptions(path: ApiEndpoints.rateAppointment(sessionId)),
        error: e,
        type: DioExceptionType.unknown,
      );
    }
  }
}
