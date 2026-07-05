// lib/feature/notes/presentation/cubit/notes_state.dart
part of 'notes_cubit.dart';

abstract class NotesState extends Equatable {
  const NotesState();
}

class NotesInitial extends NotesState {
  @override
  List<Object?> get props => [];
}

class NotesLoading extends NotesState {
  @override
  List<Object?> get props => [];
}

class NotesLoaded extends NotesState {
  final List<MedicalNoteEntity> notes;
  final String searchQuery;

  const NotesLoaded({
    required this.notes,
    this.searchQuery = '',
  });

  List<MedicalNoteEntity> get filteredNotes {
    if (searchQuery.isEmpty) return notes;
    return notes.where((note) {
      return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  List<Object?> get props => [notes, searchQuery];
}

class NoteCreating extends NotesState {
  @override
  List<Object?> get props => [];
}

class NoteCreated extends NotesState {
  final MedicalNoteEntity note;
  const NoteCreated({required this.note});
  @override
  List<Object?> get props => [note];
}

class NoteUpdating extends NotesState {
  @override
  List<Object?> get props => [];
}

class NoteUpdated extends NotesState {
  final MedicalNoteEntity note;
  const NoteUpdated({required this.note});
  @override
  List<Object?> get props => [note];
}

class NoteDeleting extends NotesState {
  @override
  List<Object?> get props => [];
}

class NoteDeleted extends NotesState {
  @override
  List<Object?> get props => [];
}

class NotesError extends NotesState {
  final String message;
  const NotesError({required this.message});
  @override
  List<Object?> get props => [message];
}
