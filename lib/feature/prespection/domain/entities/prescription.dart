import 'package:afiete/feature/prespection/domain/entities/prescription_medication.dart';

class Prescription {
  final int id;
  final String prescriptionNumber;
  final int doctorId;
  final String doctorUsername;
  final int patientId;
  final String patientUsername;
  final int appointmentId;
  final String diagnosis;
  final String notes;
  final List<PrescriptionMedication> medications;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.prescriptionNumber,
    required this.doctorId,
    required this.doctorUsername,
    required this.patientId,
    required this.patientUsername,
    required this.appointmentId,
    required this.diagnosis,
    required this.notes,
    required this.medications,
    required this.createdAt,
    required this.updatedAt,
  });
}
