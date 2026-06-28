// feature/notes/data/models/medical_note_model.dart
import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';
import 'package:equatable/equatable.dart';

class MedicalNoteModel extends Equatable {
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

  const MedicalNoteModel({
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

  factory MedicalNoteModel.fromEntity(MedicalNoteEntity entity) {
    return MedicalNoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      visibility: entity.visibility,
      creatorUsername: entity.creatorUsername,
      creatorName: entity.creatorName,
      patientUsername: entity.patientUsername,
      noteType: entity.noteType,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // ✅ toJson مطابق للـ NoteSerializer في الـ Backend
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'is_shared': visibility == NoteVisibility.shared,
    };
  }

  factory MedicalNoteModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final isShared = json['is_shared'] == true;
    final noteType = json['note_type']?.toString();

    // تحديد الـ visibility
    final visibility = (isShared || noteType == 'SESSION')
        ? NoteVisibility.shared
        : NoteVisibility.private;

    return MedicalNoteModel(
      id: id,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      visibility: visibility,
      creatorUsername: json['creator_username']?.toString(),
      creatorName: json['creator_name']?.toString(),
      patientUsername: json['patient_username']?.toString(),
      noteType: noteType,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  MedicalNoteEntity toEntity() {
    return MedicalNoteEntity(
      id: id,
      title: title,
      content: content,
      visibility: visibility,
      creatorUsername: creatorUsername,
      creatorName: creatorName,
      patientUsername: patientUsername,
      noteType: noteType,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
