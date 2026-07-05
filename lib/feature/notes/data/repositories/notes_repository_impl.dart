// lib/feature/notes/data/repositories/note_repository_impl.dart
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

    try {
      // ✅ محاولة الحفظ في الـ remote
      final createdNote = await remoteDataSource.createNote(noteModel);

      // ✅ إذا الـ remote رجع نوت بدون ID، يعني فشل
      if (createdNote.id == null || createdNote.id!.isEmpty) {
        // ✅ نحفظ محلي كـ draft
        final localNote = MedicalNoteModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: noteModel.title,
          content: noteModel.content,
          visibility: noteModel.visibility,
          creatorUsername: noteModel.creatorUsername,
          creatorName: noteModel.creatorName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await localDataSource.saveNote(localNote);
        return localNote.toEntity();
      }

      // ✅ حفظ في الـ local
      await localDataSource.saveNote(createdNote);
      return createdNote.toEntity();
    } catch (e) {
      print('❌ Create note failed: $e');
      // ✅ Fallback: حفظ محلي
      final localNote = MedicalNoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: noteModel.title,
        content: noteModel.content,
        visibility: noteModel.visibility,
        creatorUsername: noteModel.creatorUsername,
        creatorName: noteModel.creatorName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await localDataSource.saveNote(localNote);
      return localNote.toEntity();
    }
  }

  @override
  Future<MedicalNoteEntity> updateNote(MedicalNoteEntity note) async {
    final noteModel = MedicalNoteModel.fromEntity(note);

    try {
      final updatedNote = await remoteDataSource.updateNote(noteModel);
      await localDataSource.updateNote(updatedNote);
      return updatedNote.toEntity();
    } catch (e) {
      print('❌ Update note failed: $e');
      // ✅ Fallback: تحديث محلي
      await localDataSource.updateNote(noteModel);
      return note;
    }
  }

  @override
  Future<void> deleteNote(String noteId) async {
    // ✅ حذف محلي أولاً
    await localDataSource.deleteNote(noteId);

    try {
      // ✅ محاولة حذف من الـ remote
      await remoteDataSource.deleteNote(noteId);
    } catch (e) {
      print('⚠️ Remote delete failed: $e');
      // ✅ ما نرمي exception، الحذف المحلي كافي
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
    } catch (e) {
      print('⚠️ Remote get notes failed: $e');
      // ✅ Fallback: من الـ local
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
      if (doctors.isNotEmpty) {
        await localDataSource.saveRegisteredDoctors(doctors);
        return doctors;
      }
      // ✅ إذا الـ remote رجع فاضي، نجرب من الـ local
      return await localDataSource.getRegisteredDoctors();
    } catch (e) {
      print('⚠️ Remote get doctors failed: $e');
      // ✅ Fallback: من الـ local
      return await localDataSource.getRegisteredDoctors();
    }
  }
}
