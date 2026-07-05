// lib/feature/prespection/presentation/bloc/patient_prescriptions_state.dart
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

class PrescriptionHtmlLoading extends PatientPrescriptionsState {}

class PrescriptionHtmlLoaded extends PatientPrescriptionsState {
  final String htmlContent;
  final int prescriptionId;

  PrescriptionHtmlLoaded({
    required this.htmlContent,
    required this.prescriptionId,
  });
}

class PrescriptionHtmlError extends PatientPrescriptionsState {
  final String message;

  PrescriptionHtmlError(this.message);
}

class PatientPrescriptionsError extends PatientPrescriptionsState {
  final String message;

  PatientPrescriptionsError(this.message);
}
