import '../entities/prescription.dart';

abstract class PatientPrescriptionRepository {
  Future<List<Prescription>> getPrescriptions();
  Future<Prescription> getPrescriptionDetail(int id);
}
