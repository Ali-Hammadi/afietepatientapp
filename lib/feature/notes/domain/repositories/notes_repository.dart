// feature/notes/domain/repositories/note_repository.dart
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';

abstract class NoteRepository {
  Future<MedicalNoteEntity> createNote(MedicalNoteEntity note);
  Future<MedicalNoteEntity> updateNote(MedicalNoteEntity note);
  Future<void> deleteNote(String noteId);
  Future<MedicalNoteEntity?> getNoteById(String noteId);
  Future<List<MedicalNoteEntity>> getAllNotes();
  Future<List<MedicalNoteEntity>> getPrivateNotes();
  Future<List<MedicalNoteEntity>> getSharedNotes();
  Future<List<DoctorEntity>> getRegisteredDoctors();
}
