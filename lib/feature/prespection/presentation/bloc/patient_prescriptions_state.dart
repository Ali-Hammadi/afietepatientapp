import '../../domain/entities/prescription.dart';

abstract class PatientPrescriptionsState {}

class PatientPrescriptionsInitial extends PatientPrescriptionsState {}

class PatientPrescriptionsLoading extends PatientPrescriptionsState {}

class PatientPrescriptionsLoaded extends PatientPrescriptionsState {
  final List<Prescription> prescriptions;

  PatientPrescriptionsLoaded(this.prescriptions);
}

class PatientPrescriptionDetailLoading extends PatientPrescriptionsState {}

class PatientPrescriptionDetailLoaded extends PatientPrescriptionsState {
  final Prescription prescription;

  PatientPrescriptionDetailLoaded(this.prescription);
}

class PatientPrescriptionsError extends PatientPrescriptionsState {
  final String message;

  PatientPrescriptionsError(this.message);
}
