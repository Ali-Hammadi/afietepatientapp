// lib/feature/courses/presentation/cubits/courses_state.dart

import 'package:afiete/feature/cources/domain/entities/cources_entities.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();
}

class CoursesInitial extends CoursesState {
  @override
  List<Object?> get props => [];
}

class CoursesLoading extends CoursesState {
  @override
  List<Object?> get props => [];
}

class CoursesLoaded extends CoursesState {
  final CourseEntity? activeCourse;
  final List<CourseEntity> archivedCourses;
  final List<DoctorEntity> doctors;

  const CoursesLoaded({
    this.activeCourse,
    this.archivedCourses = const [],
    this.doctors = const [],
  });

  @override
  List<Object?> get props => [activeCourse, archivedCourses, doctors];
}

class CoursesError extends CoursesState {
  final String message;
  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
