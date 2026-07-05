// lib/feature/notes/presentation/pages/notes_list_screen.dart
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
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
  final _searchController = TextEditingController();

  // ✅ استخدام cubit مباشرة من GetIt
  late final NotesCubit _cubit;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _cubit = sl<NotesCubit>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ تحميل البيانات مرة واحدة
    if (!_initialized) {
      _initialized = true;
      _cubit.loadNotes();
      _cubit.loadDoctors();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsStrings.medicalNotes),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _cubit.refreshNotes(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: SettingsStrings.searchNotes,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _cubit.searchNotes('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: (value) {
                _cubit.searchNotes(value);
              },
            ),
          ),
          // ✅ Notes List
          Expanded(
            child: BlocBuilder<NotesCubit, NotesState>(
              bloc: _cubit, // ✅ ربط الـ cubit مباشرة
              builder: (context, state) {
                if (state is NotesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NotesLoaded) {
                  final filteredNotes = state.filteredNotes;

                  if (filteredNotes.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.note_add_outlined,
                              size: 64,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.searchQuery.isEmpty
                                  ? SettingsStrings.noNotesYet
                                  : '${SettingsStrings.noNotesFound} "${state.searchQuery}"',
                              style: AppStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
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
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: AppStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _cubit.loadNotes(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(SettingsStrings.retry),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const Center(child: Text('No notes available'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateNote(),
        icon: const Icon(Icons.add_rounded),
        label: Text(SettingsStrings.createNote),
      ),
    );
  }

  void _navigateToCreateNote() async {
    final result =
        await Navigator.pushNamed(context, MyRoutes.createNoteScreen);
    if (result == true && mounted) {
      _cubit.refreshNotes();
    }
  }

  void _navigateToNoteDetails(MedicalNoteEntity note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailsScreen(note: note),
      ),
    );
    if (result == true && mounted) {
      _cubit.refreshNotes();
    }
  }

  void _confirmDelete(String noteId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(SettingsStrings.deleteNote),
        content: Text(SettingsStrings.deleteNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(SettingsStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _cubit.deleteNote(noteId);
            },
            child: Text(
              SettingsStrings.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
