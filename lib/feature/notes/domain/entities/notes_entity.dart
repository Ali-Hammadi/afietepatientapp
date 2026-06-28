// feature/notes/domain/entities/medical_note_entity.dart
import 'package:equatable/equatable.dart';

enum NoteVisibility { private, shared }

class MedicalNoteEntity extends Equatable {
  final String? id;
  final String title;
  final String content;
  final NoteVisibility visibility;
  final String? creatorUsername;
  final String? creatorName;
  final String? patientUsername;
  final String? noteType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicalNoteEntity({
    this.id,
    required this.title,
    required this.content,
    required this.visibility,
    this.creatorUsername,
    this.creatorName,
    this.patientUsername,
    this.noteType,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isShared => visibility == NoteVisibility.shared;
  bool get isPrivate => visibility == NoteVisibility.private;
  bool get isCreatedByDoctor => noteType == 'SESSION';

  MedicalNoteEntity copyWith({
    String? id,
    String? title,
    String? content,
    NoteVisibility? visibility,
    String? creatorUsername,
    String? creatorName,
    String? patientUsername,
    String? noteType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalNoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      visibility: visibility ?? this.visibility,
      creatorUsername: creatorUsername ?? this.creatorUsername,
      creatorName: creatorName ?? this.creatorName,
      patientUsername: patientUsername ?? this.patientUsername,
      noteType: noteType ?? this.noteType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        visibility,
        creatorUsername,
        creatorName,
        patientUsername,
        noteType,
        createdAt,
        updatedAt,
      ];
}
