// feature/notes/presentation/pages/create_note_screen.dart
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';
import 'package:afiete/feature/notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  NoteVisibility _visibility = NoteVisibility.private;

  late final NotesCubit _notesCubit;

  @override
  void initState() {
    super.initState();
    _notesCubit = sl<NotesCubit>();
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
          title: const Text('Create Note'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
            ),
          ],
        ),
        body: BlocListener<NotesCubit, NotesState>(
          listener: (context, state) {
            if (state is NoteCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note created successfully')),
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
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter content';
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
                    segments: const [
                      ButtonSegment(
                        value: NoteVisibility.private,
                        label: Text('Private'),
                        icon: Icon(Icons.lock),
                      ),
                      ButtonSegment(
                        value: NoteVisibility.shared,
                        label: Text('Shared'),
                        icon: Icon(Icons.share),
                      ),
                    ],
                    selected: {_visibility},
                    onSelectionChanged: (Set<NoteVisibility> newSelection) {
                      setState(() {
                        _visibility = newSelection.first;
                        if (_visibility == NoteVisibility.private) {}
                      });
                    },
                  ),
                  if (_visibility == NoteVisibility.shared) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Doctor ID',
                        hintText: 'Enter doctor username',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {},
                      validator: (value) {
                        if (_visibility == NoteVisibility.shared &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter doctor ID';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveNote,
                    child: const Text('Save Note'),
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
      final now = DateTime.now();
      final note = MedicalNoteEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        visibility: _visibility,
        createdAt: now,
        updatedAt: now,
      );

      _notesCubit.createNote(note);
    }
  }
}
