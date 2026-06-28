// feature/settings/domin/entities/medical_profile_entity.dart
import 'package:equatable/equatable.dart';

class MedicalNoteEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String updatedAt;

  const MedicalNoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, content, updatedAt];
}

class MedicalPrescriptionEntity extends Equatable {
  final String prescriptionNumber;
  final String medicine;
  final String dosage;
  final String schedule;
  final String nextRefill;
  final String documentType;
  final String doctorName;
  final String capturedAt;
  final String imagePath;

  const MedicalPrescriptionEntity({
    this.prescriptionNumber = '',
    required this.medicine,
    required this.dosage,
    required this.schedule,
    required this.nextRefill,
    this.documentType = '',
    this.doctorName = '',
    this.capturedAt = '',
    this.imagePath = '',
  });

  @override
  List<Object?> get props => [
        prescriptionNumber,
        medicine,
        dosage,
        schedule,
        nextRefill,
        documentType,
        doctorName,
        capturedAt,
        imagePath,
      ];
}

class MedicalProfileEntity extends Equatable {
  final List<MedicalPrescriptionEntity> prescriptions;
  final List<MedicalNoteEntity> notes;

  const MedicalProfileEntity({
    this.prescriptions = const [],
    this.notes = const [],
  });

  @override
  List<Object?> get props => [prescriptions, notes];
}
