part of 'doctors_cubit.dart';

abstract class DoctorsState extends Equatable {
  const DoctorsState();

  @override
  List<Object?> get props => [];
}

class DoctorsInitial extends DoctorsState {
  const DoctorsInitial();
}

class DoctorsLoading extends DoctorsState {
  const DoctorsLoading();
}

// داخل ملف doctors_state.dart

class DoctorsLoaded extends DoctorsState {
  final List<DoctorEntity> doctors;
  final List<SpecialtyEntity> specialties; // إضافة قائمة التخصصات هنا
  final int? selectedSpecialtyId; // تخزين الـ id المحدد حالياً بدلاً من النص

  const DoctorsLoaded(this.doctors, this.specialties,
      {this.selectedSpecialtyId});

  @override
  List<Object?> get props => [doctors, specialties, selectedSpecialtyId];
}

class DoctorsError extends DoctorsState {
  final String message;

  const DoctorsError(this.message);

  @override
  List<Object> get props => [message];
}

// Single doctor states
class DoctorLoading extends DoctorsState {
  const DoctorLoading();
}

class DoctorLoaded extends DoctorsState {
  final DoctorEntity doctor;

  const DoctorLoaded(this.doctor);

  @override
  List<Object> get props => [doctor];
}

class DoctorError extends DoctorsState {
  final String message;

  const DoctorError(this.message);

  @override
  List<Object> get props => [message];
}
