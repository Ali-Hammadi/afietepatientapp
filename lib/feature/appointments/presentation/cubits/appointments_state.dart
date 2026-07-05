part of 'appointments_cubit.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();
}

class AppointmentsInitial extends AppointmentsState {
  @override
  List<Object?> get props => [];
}

class AppointmentsLoading extends AppointmentsState {
  @override
  List<Object?> get props => [];
}

class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentEntity> upcomingAppointments;
  final List<AppointmentEntity> pastAppointments;
  final List<AppointmentEntity> missedAppointments; // ✅ جديد
  final List<AppointmentEntity> canceledAppointments;
  final List<DoctorEntity> doctors;

  const AppointmentsLoaded(
    this.upcomingAppointments,
    this.pastAppointments,
    this.missedAppointments, // ✅ جديد
    this.canceledAppointments, {
    this.doctors = const [],
  });

  List<AppointmentEntity> get appointments => [
        ...upcomingAppointments,
        ...pastAppointments,
        ...missedAppointments,
        ...canceledAppointments,
      ];

  @override
  List<Object?> get props => [
        upcomingAppointments,
        pastAppointments,
        missedAppointments, // ✅ جديد
        canceledAppointments,
        doctors,
      ];
}

class AppointmentsError extends AppointmentsState {
  final String message;
  const AppointmentsError(this.message);

  @override
  List<Object?> get props => [message];
}
