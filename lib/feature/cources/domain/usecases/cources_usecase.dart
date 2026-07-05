// lib/feature/courses/domain/usecases/courses_usecases.dart
import 'package:afiete/core/error/failure.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/cources/domain/entities/cources_entities.dart';
import 'package:afiete/feature/cources/domain/repositories/cources_repo.dart';

import 'package:dartz/dartz.dart';

// ✅ Get Active Course
class GetActiveCourseUseCase implements UseCase<CourseEntity?, NoParams> {
  final CoursesRepository repository;
  const GetActiveCourseUseCase(this.repository);

  @override
  Future<Either<Failure, CourseEntity?>> call(NoParams params) {
    return repository.getActiveCourse();
  }
}

// ✅ Get Archived Courses
class GetArchivedCoursesUseCase
    implements UseCase<List<CourseEntity>, NoParams> {
  final CoursesRepository repository;
  const GetArchivedCoursesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CourseEntity>>> call(NoParams params) {
    return repository.getArchivedCourses();
  }
}

// ✅ End Course
class EndCourseParams {
  final int courseId;
  const EndCourseParams({required this.courseId});
}

class EndCourseUseCase implements UseCase<void, EndCourseParams> {
  final CoursesRepository repository;
  const EndCourseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(EndCourseParams params) {
    return repository.endCourse(params.courseId);
  }
}

// ✅ Request Continue
class RequestContinueParams {
  final int courseId;
  const RequestContinueParams({required this.courseId});
}

class RequestContinueUseCase implements UseCase<void, RequestContinueParams> {
  final CoursesRepository repository;
  const RequestContinueUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RequestContinueParams params) {
    return repository.requestContinue(params.courseId);
  }
}

// ✅ Decline Continue
class DeclineContinueParams {
  final int courseId;
  const DeclineContinueParams({required this.courseId});
}

class DeclineContinueUseCase implements UseCase<void, DeclineContinueParams> {
  final CoursesRepository repository;
  const DeclineContinueUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeclineContinueParams params) {
    return repository.declineContinue(params.courseId);
  }
}
