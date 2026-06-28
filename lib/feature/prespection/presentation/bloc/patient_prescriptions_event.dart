abstract class PatientPrescriptionsEvent {}

class LoadPatientPrescriptions extends PatientPrescriptionsEvent {}

class LoadPatientPrescriptionDetail extends PatientPrescriptionsEvent {
  final int id;

  LoadPatientPrescriptionDetail(this.id);
}
