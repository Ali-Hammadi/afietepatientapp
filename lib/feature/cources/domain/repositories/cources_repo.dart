// lib/feature/courses/domain/repositories/courses_repository.dart
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/feature/cources/domain/entities/cources_entities.dart';
import 'package:dartz/dartz.dart';

abstract class CoursesRepository {
  Future<Either<Failure, CourseEntity?>> getActiveCourse();
  Future<Either<Failure, List<CourseEntity>>> getArchivedCourses();
  Future<Either<Failure, void>> endCourse(int courseId);
  Future<Either<Failure, void>> requestContinue(int courseId);
  Future<Either<Failure, void>> declineContinue(int courseId);
}
