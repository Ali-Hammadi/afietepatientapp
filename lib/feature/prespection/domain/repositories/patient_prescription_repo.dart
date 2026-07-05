// lib/feature/prespection/domain/repositories/patient_prescription_repo.dart
import '../../domain/entities/prescription.dart';

abstract class PatientPrescriptionRepository {
  Future<List<Prescription>> getPrescriptions();
  Future<Prescription> getPrescriptionDetail(int id);
  Future<String> downloadPrescriptionHtml(int id);
}
