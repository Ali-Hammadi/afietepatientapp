// feature/notes/presentation/cubit/notes_cubit.dart

import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';
import 'package:afiete/feature/notes/domain/usecases/notes_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final GetNotesUseCase getNotesUseCase;

  List<MedicalNoteEntity> _allNotes = [];

  NotesCubit({
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.getNotesUseCase,
  }) : super(NotesInitial());

  Future<void> loadNotes() async {
    emit(NotesLoading());
    try {
      _allNotes = await getNotesUseCase();
      emit(NotesLoaded(notes: _allNotes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  Future<void> searchNotes(String query) async {
    if (state is NotesLoaded) {
      emit(NotesLoaded(notes: _allNotes, searchQuery: query));
    }
  }

  Future<void> createNote(MedicalNoteEntity note) async {
    emit(NoteCreating());
    try {
      final createdNote = await createNoteUseCase(note);
      _allNotes.insert(0, createdNote);
      emit(NotesLoaded(notes: _allNotes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
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
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  // ✅ Refresh from server
  Future<void> refreshNotes() async {
    try {
      _allNotes = await getNotesUseCase();
      emit(NotesLoaded(notes: _allNotes));
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }
}
