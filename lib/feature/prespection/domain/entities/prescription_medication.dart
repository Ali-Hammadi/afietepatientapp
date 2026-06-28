class PrescriptionMedication {
  final int id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String notes;

  PrescriptionMedication({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.notes,
  });
}
