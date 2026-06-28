// feature/notes/presentation/pages/notes_list_screen.dart
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';
import 'package:afiete/feature/notes/presentation/cubit/notes_cubit.dart';
import 'package:afiete/feature/notes/presentation/pages/notes_details_screen.dart';
import 'package:afiete/feature/notes/presentation/widgets/note_carde.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  late final NotesCubit _notesCubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesCubit = sl<NotesCubit>()..loadNotes();
  }

  @override
  void dispose() {
    _notesCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotesCubit>.value(
      value: _notesCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medical Notes'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _notesCubit.loadNotes(),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _notesCubit.searchNotes('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  _notesCubit.searchNotes(value);
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<NotesCubit, NotesState>(
                builder: (context, state) {
                  if (state is NotesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NotesLoaded) {
                    final filteredNotes = state.filteredNotes;

                    if (filteredNotes.isEmpty) {
                      return Center(
                        child: Text(
                          state.searchQuery.isEmpty
                              ? 'No notes yet. Create your first note!'
                              : 'No notes found for "${state.searchQuery}"',
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];
                        return NoteCard(
                          note: note,
                          onTap: () => _navigateToNoteDetails(note),
                          onDelete: () => _confirmDelete(note.id!),
                        );
                      },
                    );
                  }

                  if (state is NotesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _notesCubit.loadNotes(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const Center(child: Text('No notes available'));
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToCreateNote(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _navigateToCreateNote() async {
    final result =
        await Navigator.pushNamed(context, MyRoutes.createNoteScreen);
    if (result == true) {
      _notesCubit.loadNotes();
    }
  }

  void _navigateToNoteDetails(MedicalNoteEntity note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailsScreen(
          note: note,
        ),
      ),
    );
    if (result == true) {
      _notesCubit.loadNotes();
    }
  }

  void _confirmDelete(String noteId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _notesCubit.deleteNote(noteId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
