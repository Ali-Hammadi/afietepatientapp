// lib/feature/prespection/presentation/bloc/patient_prescriptions_event.dart
abstract class PatientPrescriptionsEvent {}

class LoadPatientPrescriptions extends PatientPrescriptionsEvent {}

class LoadPatientPrescriptionDetail extends PatientPrescriptionsEvent {
  final int id;

  LoadPatientPrescriptionDetail(this.id);
}

class DownloadPrescriptionHtmlEvent extends PatientPrescriptionsEvent {
  final int id;

  DownloadPrescriptionHtmlEvent(this.id);
}
