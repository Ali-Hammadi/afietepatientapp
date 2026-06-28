import 'package:afiete/feature/prespection/domain/repositories/patient_prescription_repo.dart';

import '../entities/prescription.dart';

class GetPatientPrescriptions {
  final PatientPrescriptionRepository repository;

  GetPatientPrescriptions(this.repository);

  Future<List<Prescription>> call() async {
    return await repository.getPrescriptions();
  }
}

class GetPatientPrescriptionDetail {
  final PatientPrescriptionRepository repository;

  GetPatientPrescriptionDetail(this.repository);

  Future<Prescription> call(int id) async {
    return await repository.getPrescriptionDetail(id);
  }
}
