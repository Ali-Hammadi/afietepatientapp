import '../../domain/entities/prescription_medication.dart';

class PrescriptionMedicationModel extends PrescriptionMedication {
  PrescriptionMedicationModel({
    required int id,
    required String medicationName,
    required String dosage,
    required String frequency,
    required String duration,
    required String notes,
  }) : super(
          id: id,
          medicationName: medicationName,
          dosage: dosage,
          frequency: frequency,
          duration: duration,
          notes: notes,
        );

  factory PrescriptionMedicationModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionMedicationModel(
      id: json['id'] as int,
      medicationName: json['medication_name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication_name': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'notes': notes,
    };
  }
}
