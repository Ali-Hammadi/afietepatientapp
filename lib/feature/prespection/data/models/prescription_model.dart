import '../../domain/entities/prescription.dart';
import 'prescription_medication_model.dart';

class PrescriptionModel extends Prescription {
  PrescriptionModel({
    required super.id,
    required super.prescriptionNumber,
    required super.doctorId,
    required super.doctorUsername,
    required super.patientId,
    required super.patientUsername,
    required super.appointmentId,
    required super.diagnosis,
    required super.notes,
    required List<PrescriptionMedicationModel> super.medications,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as int,
      prescriptionNumber: json['prescription_number'] as String,
      doctorId: json['doctor_id'] as int,
      doctorUsername: json['doctor_username'] as String,
      patientId: json['patient_id'] as int,
      patientUsername: json['patient_username'] as String,
      appointmentId: json['appointment_id'] as int,
      diagnosis: json['diagnosis'] as String,
      notes: json['notes'] as String? ?? '',
      medications: (json['medications'] as List<dynamic>)
          .map((m) =>
              PrescriptionMedicationModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_number': prescriptionNumber,
      'doctor_id': doctorId,
      'doctor_username': doctorUsername,
      'patient_id': patientId,
      'patient_username': patientUsername,
      'appointment_id': appointmentId,
      'diagnosis': diagnosis,
      'notes': notes,
      'medications': medications
          .map((m) => (m as PrescriptionMedicationModel).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
