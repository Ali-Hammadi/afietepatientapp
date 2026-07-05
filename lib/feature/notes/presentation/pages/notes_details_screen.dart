// lib/feature/notes/presentation/pages/note_details_screen.dart
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/notes/domain/entities/notes_entity.dart';
import 'package:afiete/feature/notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  DoctorEntity? _selectedDoctor;
  bool _isSaving = false;

  late final NotesCubit _notesCubit;

  bool get _isFromDoctor => widget.note.isCreatedByDoctor;

  @override
  void initState() {
    super.initState();
    _notesCubit = sl<NotesCubit>();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _visibility = widget.note.visibility;

    _notesCubit.loadDoctors().then((_) {
      if (_visibility == NoteVisibility.shared &&
          widget.note.creatorUsername != null) {
        final doctors = _notesCubit.doctors;
        if (doctors.isNotEmpty) {
          setState(() {
            _selectedDoctor = doctors.firstWhere(
              (d) => d.doctorUsername == widget.note.creatorUsername,
              orElse: () => doctors.first,
            );
          });
        }
      }
    });
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
              centerTitle: true,
              title: Text(
                _isFromDoctor
                    ? SettingsStrings.noteDetails
                    : SettingsStrings.editNote,
              ),
              actions: [
                if (!_isFromDoctor)
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
                if (!_isFromDoctor)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: colorScheme.error,
                    onPressed: _deleteNote,
                  ),
              ],
            ),
            body: BlocListener<NotesCubit, NotesState>(
              bloc: _notesCubit,
              listener: (context, state) {
                if (state is NoteUpdated) {
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(SettingsStrings.noteUpdatedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                } else if (state is NoteDeleted) {
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(SettingsStrings.noteDeletedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                } else if (state is NoteUpdating || state is NoteDeleting) {
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
                      // ✅ Banner إذا النوت من الطبيب
                      if (_isFromDoctor)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  SettingsStrings.readOnlyNote,
                                  style: AppStyles.bodySmall.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ✅ معلومات النوت
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy - HH:mm',
                                    SettingsStrings.isArabic ? 'ar' : 'en',
                                  ).format(widget.note.createdAt),
                                  style: AppStyles.bodySmall.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.note.creatorName != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.note.creatorName!,
                                    style: AppStyles.bodySmall.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // ✅ حقل العنوان
                      TextFormField(
                        controller: _titleController,
                        enabled: !_isFromDoctor,
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
                        enabled: !_isFromDoctor,
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
                      AbsorbPointer(
                        absorbing: _isFromDoctor,
                        child: SegmentedButton<NoteVisibility>(
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
                          onSelectionChanged:
                              (Set<NoteVisibility> newSelection) {
                            setState(() {
                              _visibility = newSelection.first;
                              if (_visibility == NoteVisibility.private) {
                                _selectedDoctor = null;
                              }
                            });
                          },
                        ),
                      ),

                      // ✅ Doctor Dropdown - مع إصلاح Layout Error
                      if (_visibility == NoteVisibility.shared) ...[
                        const SizedBox(height: 16),
                        Text(
                          SettingsStrings.selectDoctor,
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AbsorbPointer(
                          absorbing: _isFromDoctor,
                          child: BlocBuilder<NotesCubit, NotesState>(
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
                                isExpanded: true, // ✅ مهم
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
                                      mainAxisSize: MainAxisSize.min, // ✅ مهم
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundImage: doctor.imageUrl !=
                                                      null &&
                                                  doctor.imageUrl!.isNotEmpty
                                              ? NetworkImage(doctor.imageUrl!)
                                              : null,
                                          child: doctor.imageUrl == null ||
                                                  doctor.imageUrl!.isEmpty
                                              ? const Icon(Icons.person,
                                                  size: 16)
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          // ✅ مهم - بدل Expanded
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                doctor.name ??
                                                    doctor.doctorUsername,
                                                style: AppStyles.bodySmall
                                                    .copyWith(
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
                        ),
                      ],

                      // ✅ زر الحفظ
                      if (!_isFromDoctor) ...[
                        const SizedBox(height: 32),
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

    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      visibility: _visibility,
      creatorUsername: _selectedDoctor?.doctorUsername,
      creatorName: _selectedDoctor?.name,
      updatedAt: DateTime.now(),
    );

    _notesCubit.updateNote(updatedNote);
  }

  void _deleteNote() {
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
              _notesCubit.deleteNote(widget.note.id!);
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
