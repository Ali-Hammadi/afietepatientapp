// lib/feature/notes/presentation/cubit/notes_cubit.dart
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';
import 'package:afiete/feature/notes/domain/repositories/notes_repository.dart';
import 'package:afiete/feature/notes/domain/usecases/notes_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final GetNotesUseCase getNotesUseCase;
  final NoteRepository repository;

  List<MedicalNoteEntity> _allNotes = [];
  List<DoctorEntity> _doctors = [];
  bool _doctorsLoaded = false;

  NotesCubit({
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.getNotesUseCase,
    required this.repository,
  }) : super(NotesInitial());

  List<DoctorEntity> get doctors => _doctors;

  Future<void> loadNotes() async {
    emit(NotesLoading());
    try {
      _allNotes = await getNotesUseCase();
      emit(NotesLoaded(notes: _allNotes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  Future<void> loadDoctors() async {
    if (_doctorsLoaded) return;
    try {
      _doctors = await repository.getRegisteredDoctors();
      _doctorsLoaded = true;
    } catch (e) {
      print('⚠️ Failed to load doctors: $e');
    }
  }

  Future<void> searchNotes(String query) async {
    if (state is NotesLoaded) {
      emit(NotesLoaded(notes: _allNotes, searchQuery: query));
    }
  }

// في NotesCubit - عدل createNote
  Future<void> createNote(MedicalNoteEntity note) async {
    emit(NoteCreating());
    try {
      final createdNote = await createNoteUseCase(note);
      _allNotes.insert(0, createdNote);

      // ✅ إذا النوت ما عندو ID من الـ server، نعرض رسالة
      if (createdNote.id != null && int.tryParse(createdNote.id!) == null) {
        emit(NotesLoaded(notes: _allNotes));
        emit(NoteCreated(note: createdNote));
        emit(NotesLoaded(notes: _allNotes));
      } else {
        emit(NotesLoaded(notes: _allNotes));
        emit(NoteCreated(note: createdNote));
        emit(NotesLoaded(notes: _allNotes));
      }
    } catch (e) {
      print('❌ Create note error: $e');
      emit(NotesError(message: 'Failed to create note. Saved locally.'));
      // ✅ نحفظ محلي على أي حال
      final localNote = note.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      _allNotes.insert(0, localNote);
      emit(NotesLoaded(notes: _allNotes));
    }
  }

  Future<void> updateNote(MedicalNoteEntity note) async {
    emit(NoteUpdating());
    try {
      final updatedNote = await updateNoteUseCase(note);
      final index = _allNotes.indexWhere((n) => n.id == updatedNote.id);
      if (index != -1) {
        _allNotes[index] = updatedNote;
      }
      emit(NotesLoaded(notes: _allNotes));
      emit(NoteUpdated(note: updatedNote));
      emit(NotesLoaded(notes: _allNotes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  Future<void> deleteNote(String noteId) async {
    emit(NoteDeleting());
    try {
      await deleteNoteUseCase(noteId);
      _allNotes.removeWhere((n) => n.id == noteId);
      emit(NotesLoaded(notes: _allNotes));
      emit(NoteDeleted());
      emit(NotesLoaded(notes: _allNotes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  Future<void> refreshNotes() async {
    try {
      _allNotes = await getNotesUseCase();
      emit(NotesLoaded(notes: _allNotes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }
}
