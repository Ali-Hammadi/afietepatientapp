// lib/feature/prespection/data/repositories/patient_prescription_repository_impl.dart
import 'package:afiete/feature/prespection/domain/repositories/patient_prescription_repo.dart';

import '../../domain/entities/prescription.dart';
import '../datasources/patient_prescription_remote_datasource.dart';

class PatientPrescriptionRepositoryImpl
    implements PatientPrescriptionRepository {
  final PatientPrescriptionRemoteDataSource remoteDataSource;

  PatientPrescriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Prescription>> getPrescriptions() async {
    return await remoteDataSource.getPrescriptions();
  }

  @override
  Future<Prescription> getPrescriptionDetail(int id) async {
    return await remoteDataSource.getPrescriptionDetail(id);
  }

  @override
  Future<String> downloadPrescriptionHtml(int id) async {
    return await remoteDataSource.downloadPrescriptionHtml(id);
  }
}
