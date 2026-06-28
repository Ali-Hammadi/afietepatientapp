// feature/notes/presentation/pages/note_details_screen.dart
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';
import 'package:afiete/feature/notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteDetailsScreen extends StatefulWidget {
  final MedicalNoteEntity note;

  const NoteDetailsScreen({super.key, required this.note});

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NoteVisibility _visibility;
  late String? _doctorId;

  late final NotesCubit _notesCubit;

  @override
  void initState() {
    super.initState();
    _notesCubit = sl<NotesCubit>();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _visibility = widget.note.visibility;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _notesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotesCubit>.value(
      value: _notesCubit,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Note Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
          ],
        ),
        body: BlocListener<NotesCubit, NotesState>(
          listener: (context, state) {
            if (state is NoteUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note updated successfully')),
              );
              Navigator.pop(context, true);
            } else if (state is NoteDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted successfully')),
              );
              Navigator.pop(context, true);
            } else if (state is NotesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: SettingsStrings.title,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return SettingsStrings.enterTitle;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: SettingsStrings.contet,
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return SettingsStrings.enterContet;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Visibility',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<NoteVisibility>(
                    segments: [
                      ButtonSegment(
                        value: NoteVisibility.private,
                        label: Text(SettingsStrings.private),
                        icon: Icon(Icons.lock),
                      ),
                      ButtonSegment(
                        value: NoteVisibility.shared,
                        label: Text(SettingsStrings.shareNote),
                        icon: Icon(Icons.share),
                      ),
                    ],
                    selected: {_visibility},
                    onSelectionChanged: (Set<NoteVisibility> newSelection) {
                      setState(() {
                        _visibility = newSelection.first;
                        if (_visibility == NoteVisibility.private) {
                          _doctorId = null;
                        }
                      });
                    },
                  ),
                  if (_visibility == NoteVisibility.shared) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _doctorId ?? '',
                      decoration: InputDecoration(
                        labelText: SettingsStrings.doctorUsername,
                        hintText: SettingsStrings.enterDoctorUsername,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _doctorId = value;
                      },
                      validator: (value) {
                        if (_visibility == NoteVisibility.shared &&
                            (value == null || value.isEmpty)) {
                          return SettingsStrings.enterDoctorUsername;
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveNote,
                    child: Text(SettingsStrings.save),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final updatedNote = widget.note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        visibility: _visibility,
        updatedAt: DateTime.now(),
      );

      _notesCubit.updateNote(updatedNote);
    }
  }

  void _deleteNote() {
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
              _notesCubit.deleteNote(widget.note.id!);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
