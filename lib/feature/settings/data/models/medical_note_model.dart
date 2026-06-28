// feature/settings/data/models/medical_note_model.dart
import 'package:afiete/feature/settings/domin/entities/medical_profile_entity.dart';
import 'package:equatable/equatable.dart';

class MedicalNoteModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final String updatedAt;

  const MedicalNoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  factory MedicalNoteModel.fromJson(Map<String, dynamic> json) {
    return MedicalNoteModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      updatedAt: json['updatedAt'] ?? json['updated_at'] ?? '',
    );
  }

  MedicalNoteEntity toEntity() => MedicalNoteEntity(
        id: id,
        title: title,
        content: content,
        updatedAt: updatedAt,
      );

  @override
  List<Object?> get props => [id, title, content, updatedAt];
}
