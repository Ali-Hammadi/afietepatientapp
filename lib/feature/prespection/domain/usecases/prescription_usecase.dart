// lib/feature/prespection/domain/usecases/prescription_usecase.dart
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

class DownloadPrescriptionHtml {
  final PatientPrescriptionRepository repository;

  DownloadPrescriptionHtml(this.repository);

  Future<String> call(int id) async {
    return await repository.downloadPrescriptionHtml(id);
  }
}
