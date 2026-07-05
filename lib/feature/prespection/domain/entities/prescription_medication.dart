// lib/feature/prespection/domain/entities/prescription_medication.dart
import 'package:equatable/equatable.dart';

class PrescriptionMedication extends Equatable {
  final int id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String notes;

  const PrescriptionMedication({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        medicationName,
        dosage,
        frequency,
        duration,
        notes,
      ];
}
