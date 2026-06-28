// feature/notes/data/repositories/note_repository_impl.dart
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/notes/data/datasources/notes_local_datasource.dart';
import 'package:afiete/feature/notes/data/datasources/notes_remote_datasource.dart';
import 'package:afiete/feature/notes/data/models/notes_model.dart';
import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';
import 'package:afiete/feature/notes/domain/repositories/notes_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<MedicalNoteEntity> createNote(MedicalNoteEntity note) async {
    final noteModel = MedicalNoteModel.fromEntity(note);

    final createdNote = await remoteDataSource.createNote(noteModel);
    await localDataSource.saveNote(createdNote);
    return createdNote.toEntity();
  }

  // ✅ يرجع MedicalNoteEntity
  @override
  Future<MedicalNoteEntity> updateNote(MedicalNoteEntity note) async {
    final noteModel = MedicalNoteModel.fromEntity(note);

    final updatedNote = await remoteDataSource.updateNote(noteModel);
    await localDataSource.updateNote(updatedNote);
    return updatedNote.toEntity();
  }

  @override
  Future<void> deleteNote(String noteId) async {
    // ✅ حذف محلي
    await localDataSource.deleteNote(noteId);

    try {
      // ✅ حذف من السيرفر
      await remoteDataSource.deleteNote(noteId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MedicalNoteEntity?> getNoteById(String noteId) async {
    final notes = await localDataSource.getNotes();
    try {
      return notes.firstWhere((note) => note.id == noteId).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MedicalNoteEntity>> getAllNotes() async {
    try {
      final remoteNotes = await remoteDataSource.getNotes();
      // ✅ مزامنة مع الـ local
      await localDataSource.syncNotes(remoteNotes);
      return remoteNotes.map((note) => note.toEntity()).toList();
    } catch (_) {
      final notes = await localDataSource.getNotes();
      return notes.map((note) => note.toEntity()).toList();
    }
  }

  @override
  Future<List<MedicalNoteEntity>> getPrivateNotes() async {
    final notes = await localDataSource.getNotes();
    return notes
        .where((note) => note.visibility == NoteVisibility.private)
        .map((note) => note.toEntity())
        .toList();
  }

  @override
  Future<List<MedicalNoteEntity>> getSharedNotes() async {
    final notes = await localDataSource.getNotes();
    return notes
        .where((note) => note.visibility == NoteVisibility.shared)
        .map((note) => note.toEntity())
        .toList();
  }

  @override
  Future<List<DoctorEntity>> getRegisteredDoctors() async {
    try {
      final doctors = await remoteDataSource.getRegisteredDoctors();
      await localDataSource.saveRegisteredDoctors(doctors);
      return doctors;
    } catch (_) {
      final doctors = await localDataSource.getRegisteredDoctors();
      return doctors;
    }
  }
}
