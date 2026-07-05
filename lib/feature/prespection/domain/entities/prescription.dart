// lib/feature/prespection/domain/entities/prescription.dart
import 'package:afiete/feature/prespection/domain/entities/prescription_medication.dart';
import 'package:equatable/equatable.dart';

class Prescription extends Equatable {
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

  const Prescription({
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

  @override
  List<Object?> get props => [
        id,
        prescriptionNumber,
        doctorId,
        doctorUsername,
        patientId,
        patientUsername,
        appointmentId,
        diagnosis,
        notes,
        medications,
        createdAt,
        updatedAt,
      ];
}
