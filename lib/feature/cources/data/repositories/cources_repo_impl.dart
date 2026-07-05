// lib/feature/courses/data/repositories/courses_repository_impl.dart
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/cources/data/datasources/cources_remote_datasource.dart';
import 'package:afiete/feature/cources/domain/entities/cources_entities.dart';
import 'package:afiete/feature/cources/domain/repositories/cources_repo.dart';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  final CoursesRemoteDataSource dataSource;
  const CoursesRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, CourseEntity?>> getActiveCourse() async {
    try {
      final result = await dataSource.getActiveCourse();
      return Right<Failure, CourseEntity?>(result);
    } on DioException catch (e) {
      return Left<Failure, CourseEntity?>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, CourseEntity?>(
        ServerFailure('Unable to load active course.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getArchivedCourses() async {
    try {
      final result = await dataSource.getArchivedCourses();
      return Right<Failure, List<CourseEntity>>(result);
    } on DioException catch (e) {
      return Left<Failure, List<CourseEntity>>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, List<CourseEntity>>(
        ServerFailure('Unable to load archived courses.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> endCourse(int courseId) async {
    try {
      await dataSource.endCourse(courseId);
      return Right<Failure, void>(null);
    } on DioException catch (e) {
      return Left<Failure, void>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, void>(ServerFailure('Could not end course.'));
    }
  }

  @override
  Future<Either<Failure, void>> requestContinue(int courseId) async {
    try {
      await dataSource.requestContinue(courseId);
      return Right<Failure, void>(null);
    } on DioException catch (e) {
      return Left<Failure, void>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, void>(ServerFailure('Could not request continue.'));
    }
  }

  @override
  Future<Either<Failure, void>> declineContinue(int courseId) async {
    try {
      await dataSource.declineContinue(courseId);
      return Right<Failure, void>(null);
    } on DioException catch (e) {
      return Left<Failure, void>(ServerFailure.fromDioError(e));
    } catch (_) {
      return Left<Failure, void>(ServerFailure('Could not decline continue.'));
    }
  }
}
