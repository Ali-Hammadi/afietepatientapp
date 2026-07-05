// lib/feature/notes/presentation/pages/create_note_screen.dart
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
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
  DoctorEntity? _selectedDoctor;
  bool _isSaving = false;

  late final NotesCubit _notesCubit;

  @override
  void initState() {
    super.initState();
    _notesCubit = sl<NotesCubit>();
    _notesCubit.loadDoctors();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider<NotesCubit>.value(
      value: _notesCubit,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(SettingsStrings.createNote),
              actions: [
                _isSaving
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.check_rounded),
                        onPressed: _saveNote,
                      ),
              ],
            ),
            body: BlocListener<NotesCubit, NotesState>(
              bloc: _notesCubit,
              listener: (context, state) {
                if (state is NoteCreated) {
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(SettingsStrings.noteCreatedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                } else if (state is NoteCreating) {
                  setState(() => _isSaving = true);
                } else if (state is NotesError) {
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
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
                      // ✅ حقل العنوان
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: SettingsStrings.title,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return SettingsStrings.enterTitle;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ✅ حقل المحتوى
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: SettingsStrings.content,
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 120),
                            child: Icon(Icons.notes),
                          ),
                        ),
                        maxLines: 10,
                        minLines: 6,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return SettingsStrings.enterContent;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // ✅ Visibility Selector
                      Text(
                        SettingsStrings.visibility,
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<NoteVisibility>(
                        segments: [
                          ButtonSegment(
                            value: NoteVisibility.private,
                            label: Text(SettingsStrings.privateNote),
                            icon: const Icon(Icons.lock_outline),
                          ),
                          ButtonSegment(
                            value: NoteVisibility.shared,
                            label: Text(SettingsStrings.sharedNote),
                            icon: const Icon(Icons.share_outlined),
                          ),
                        ],
                        selected: {_visibility},
                        onSelectionChanged: (Set<NoteVisibility> newSelection) {
                          setState(() {
                            _visibility = newSelection.first;
                            if (_visibility == NoteVisibility.private) {
                              _selectedDoctor = null;
                            }
                          });
                        },
                      ),

                      // ✅ Doctor Dropdown
                      if (_visibility == NoteVisibility.shared) ...[
                        const SizedBox(height: 16),
                        Text(
                          SettingsStrings.selectDoctor,
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<NotesCubit, NotesState>(
                          bloc: _notesCubit,
                          builder: (context, state) {
                            final doctors = _notesCubit.doctors;

                            if (doctors.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(SettingsStrings.noDoctorsAvailable),
                                  ],
                                ),
                              );
                            }

                            return DropdownButtonFormField<DoctorEntity>(
                              value: _selectedDoctor,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: SettingsStrings.selectDoctor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              items: doctors.map((doctor) {
                                return DropdownMenuItem<DoctorEntity>(
                                  value: doctor,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundImage:
                                            doctor.imageUrl != null &&
                                                    doctor.imageUrl!.isNotEmpty
                                                ? NetworkImage(doctor.imageUrl!)
                                                : null,
                                        child: doctor.imageUrl == null ||
                                                doctor.imageUrl!.isEmpty
                                            ? const Icon(Icons.person, size: 16)
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              doctor.name ??
                                                  doctor.doctorUsername,
                                              style:
                                                  AppStyles.bodySmall.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedDoctor = value);
                              },
                              validator: (value) {
                                if (_visibility == NoteVisibility.shared &&
                                    value == null) {
                                  return SettingsStrings.selectDoctor;
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 32),

                      // ✅ زر الحفظ
                      SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveNote,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            _isSaving
                                ? SettingsStrings.saving
                                : SettingsStrings.save,
                            style: AppStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveNote() {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final note = MedicalNoteEntity(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      visibility: _visibility,
      creatorUsername: _selectedDoctor?.doctorUsername,
      creatorName: _selectedDoctor?.name,
      createdAt: now,
      updatedAt: now,
    );

    _notesCubit.createNote(note);
  }
}
