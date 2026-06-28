// domain/usecases/create_note_usecase.dart

import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';
import 'package:afiete/feature/notes/domain/repositories/notes_repository.dart';

class CreateNoteUseCase {
  final NoteRepository repository;

  CreateNoteUseCase(this.repository);

  Future<MedicalNoteEntity> call(MedicalNoteEntity note) async {
    return await repository.createNote(note);
  }
}

class UpdateNoteUseCase {
  final NoteRepository repository;

  UpdateNoteUseCase(this.repository);
  Future<MedicalNoteEntity> call(MedicalNoteEntity note) async {
    return await repository.updateNote(note);
  }
}

class DeleteNoteUseCase {
  final NoteRepository repository;

  DeleteNoteUseCase(this.repository);

  Future<void> call(String noteId) async {
    await repository.deleteNote(noteId);
  }
}

class GetNotesUseCase {
  final NoteRepository repository;

  GetNotesUseCase(this.repository);

  Future<List<MedicalNoteEntity>> call() async {
    return await repository.getAllNotes();
  }
}
