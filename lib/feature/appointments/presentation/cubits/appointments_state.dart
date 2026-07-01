part of 'appointments_cubit.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object> get props => [];
}

class SlotsLoading extends AppointmentsState {
  const SlotsLoading();
}

class SlotsLoaded extends AppointmentsState {
  final List<dynamic> availableSlots;

  const SlotsLoaded(this.availableSlots);

  @override
  List<Object> get props => [availableSlots];
}

class AppointmentsInitial extends AppointmentsState {
  const AppointmentsInitial();
}

class AppointmentsLoading extends AppointmentsState {
  const AppointmentsLoading();
}

class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentEntity> upcomingAppointments;
  final List<AppointmentEntity> pastAppointments;
  final List<AppointmentEntity> missedAppointments;
  final List<AppointmentEntity> canceledAppointments;
  final List<DoctorEntity>? doctors;

  const AppointmentsLoaded(
    this.upcomingAppointments,
    this.pastAppointments,
    this.missedAppointments,
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
  List<Object> get props => [
        upcomingAppointments,
        pastAppointments,
        missedAppointments,
        canceledAppointments,
        doctors ?? const <DoctorEntity>[],
      ];
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object> get props => [message];
}
