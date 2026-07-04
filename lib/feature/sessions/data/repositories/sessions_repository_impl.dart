import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/sessions/data/datasources/sessions_remote_datasource.dart';
import 'package:afiete/feature/sessions/domain/entities/review_entity.dart';
import 'package:afiete/feature/sessions/domain/entities/session_entity.dart';
import 'package:afiete/feature/sessions/domain/repositories/sessions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsRemoteDataSource dataSource;

  const SessionsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<SessionEntity>>> getUpcomingSessions() async {
    try {
      final result = await dataSource.getUpcomingSessions();
      return Right<Failure, List<SessionEntity>>(result);
    } on DioException catch (e) {
      return Left<Failure, List<SessionEntity>>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, List<SessionEntity>>(
        ServerFailure('Unable to load upcoming sessions.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getPastSessions() async {
    try {
      final result = await dataSource.getPastSessions();
      return Right<Failure, List<SessionEntity>>(result);
    } on DioException catch (e) {
      return Left<Failure, List<SessionEntity>>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, List<SessionEntity>>(
        ServerFailure('Unable to load past sessions.'),
      );
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> joinSession(dynamic sessionId) async {
    try {
      final result = await dataSource.joinSession(sessionId);
      return Right<Failure, SessionEntity>(result);
    } on DioException catch (e) {
      return Left<Failure, SessionEntity>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, SessionEntity>(
        ServerFailure('Could not join session.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelSession({
    required dynamic sessionId,
    required String username,
  }) async {
    try {
      await dataSource.cancelSession(sessionId: sessionId, username: username);
      return Right<Failure, void>(null);
    } on DioException catch (e) {
      return Left<Failure, void>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, void>(ServerFailure('Could not cancel session.'));
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> rescheduleSession({
    required dynamic sessionId,
    required DateTime newScheduledAt,
  }) async {
    try {
      final result = await dataSource.rescheduleSession(
        sessionId: sessionId,
        newScheduledAt: newScheduledAt,
      );
      return Right<Failure, SessionEntity>(result);
    } on DioException catch (e) {
      return Left<Failure, SessionEntity>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, SessionEntity>(
        ServerFailure('Could not reschedule session.'),
      );
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> addReview({
    required dynamic appointmentId,
    required int rating,
    String? comment,
  }) async {
    try {
      final result = await dataSource.addReview(
        appointmentId: appointmentId,
        rating: rating,
        comment: comment,
      );
      return Right<Failure, ReviewEntity>(result as ReviewEntity);
    } on DioException catch (e) {
      return Left<Failure, ReviewEntity>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, ReviewEntity>(
        ServerFailure('Could not submit review.'),
      );
    }
  }
}
