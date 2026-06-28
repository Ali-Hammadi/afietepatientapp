// feature/notes/presentation/cubit/notes_state.dart
part of 'notes_cubit.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

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
      final titleMatch =
          note.title.toLowerCase().contains(searchQuery.toLowerCase());
      final contentMatch =
          note.content.toLowerCase().contains(searchQuery.toLowerCase());
      return titleMatch || contentMatch;
    }).toList();
  }

  @override
  List<Object?> get props => [notes, searchQuery];
}

class NoteCreating extends NotesState {}

class NoteCreated extends NotesState {}

class NoteUpdating extends NotesState {}

class NoteUpdated extends NotesState {}

class NoteDeleting extends NotesState {}

class NoteDeleted extends NotesState {}

class DoctorsLoading extends NotesState {}

class DoctorsLoaded extends NotesState {
  final List<DoctorEntity> doctors;

  const DoctorsLoaded({required this.doctors});

  @override
  List<Object?> get props => [doctors];
}

class NoteSharing extends NotesState {}

class NoteShared extends NotesState {}

class NotesError extends NotesState {
  final String message;

  const NotesError({required this.message});

  @override
  List<Object?> get props => [message];
}
