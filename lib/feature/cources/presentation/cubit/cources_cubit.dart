// lib/feature/courses/presentation/cubits/courses_cubit.dart
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/cources/domain/entities/cources_entities.dart';
import 'package:afiete/feature/cources/domain/usecases/cources_usecase.dart';
import 'package:afiete/feature/cources/presentation/cubit/cources_state.dart';

import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final GetActiveCourseUseCase getActiveCourseUseCase;
  final GetArchivedCoursesUseCase getArchivedCoursesUseCase;
  final EndCourseUseCase endCourseUseCase;
  final RequestContinueUseCase requestContinueUseCase;
  final DeclineContinueUseCase declineContinueUseCase;
  final GetAllDoctorsUseCase? getAllDoctorsUseCase;

  List<DoctorEntity> _cachedDoctors = const [];

  CoursesCubit({
    required this.getActiveCourseUseCase,
    required this.getArchivedCoursesUseCase,
    required this.endCourseUseCase,
    required this.requestContinueUseCase,
    required this.declineContinueUseCase,
    this.getAllDoctorsUseCase,
  }) : super(CoursesInitial());

  Future<void> loadCourses({bool forceRefresh = false}) async {
    if (state is CoursesLoading && !forceRefresh) return;

    emit(CoursesLoading());

    try {
      // ✅ جلب الأطباء أولاً (إذا لزم)
      if (getAllDoctorsUseCase != null && _cachedDoctors.isEmpty) {
        final doctorResult = await getAllDoctorsUseCase!(NoParams());
        doctorResult.fold(
          (failure) =>
              print('⚠️ Failed to load doctors: ${failure.errorMessage}'),
          (doctors) => _cachedDoctors = doctors,
        );
      }

      // ✅ جلب الكورسات بالتوازي (بدون الأطباء)
      final results = await Future.wait([
        getActiveCourseUseCase(NoParams()),
        getArchivedCoursesUseCase(NoParams()),
      ]);

      final activeResult = results[0] as Either<dynamic, CourseEntity?>;
      final archivedResult = results[1] as Either<dynamic, List<CourseEntity>>;

      activeResult.fold(
        (failure) {
          print('❌ Failed to load active course: ${failure.errorMessage}');
          emit(CoursesError(failure.errorMessage));
        },
        (activeCourse) {
          archivedResult.fold(
            (failure) {
              print(
                  '❌ Failed to load archived courses: ${failure.errorMessage}');
              emit(CoursesError(failure.errorMessage));
            },
            (archivedCourses) {
              emit(CoursesLoaded(
                activeCourse: activeCourse,
                archivedCourses: archivedCourses,
                doctors: _cachedDoctors,
              ));
            },
          );
        },
      );
    } catch (e) {
      print('❌ Error loading courses: $e');
      emit(CoursesError('Failed to load courses. Please try again.'));
    }
  }

  Future<bool> endCourse(int courseId) async {
    final result = await endCourseUseCase(EndCourseParams(courseId: courseId));
    return result.fold(
      (failure) {
        emit(CoursesError(failure.errorMessage));
        return false;
      },
      (_) {
        loadCourses(forceRefresh: true);
        return true;
      },
    );
  }

  Future<bool> requestContinue(int courseId) async {
    final result = await requestContinueUseCase(
      RequestContinueParams(courseId: courseId),
    );
    return result.fold(
      (failure) {
        emit(CoursesError(failure.errorMessage));
        return false;
      },
      (_) {
        loadCourses(forceRefresh: true);
        return true;
      },
    );
  }

  Future<bool> declineContinue(int courseId) async {
    final result = await declineContinueUseCase(
      DeclineContinueParams(courseId: courseId),
    );
    return result.fold(
      (failure) {
        emit(CoursesError(failure.errorMessage));
        return false;
      },
      (_) {
        loadCourses(forceRefresh: true);
        return true;
      },
    );
  }

  DoctorEntity? findDoctorByUsername(String username) {
    for (final doctor in _cachedDoctors) {
      if (doctor.doctorUsername == username) return doctor;
    }
    return null;
  }
}
