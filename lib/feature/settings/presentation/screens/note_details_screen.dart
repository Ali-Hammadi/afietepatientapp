// feature/settings/presentation/screens/note_details_screen.dart
import 'package:afiete/core/constants/app_colors.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/feature/settings/domin/entities/medical_profile_entity.dart';
import 'package:afiete/feature/settings/presentation/models/share_doctor_option.dart';
import 'package:flutter/material.dart';

class NoteDetailsScreen extends StatefulWidget {
  final MedicalNoteEntity note;
  final String username;
  final List<ShareDoctorOption> doctors;

  const NoteDetailsScreen({
    super.key,
    required this.note,
    required this.username,
    required this.doctors,
  });

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  ShareDoctorOption? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          SettingsStrings.noteContentLabel,
          style: AppStyles.headingMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SettingsStrings.noteTitleLabel,
              style: AppStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: SettingsStrings.noteTitleLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              SettingsStrings.noteContentLabel,
              style: AppStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: SettingsStrings.editNote,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              SettingsStrings.shareNote,
              style: AppStyles.headingSmall,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ShareDoctorOption>(
                  value: _selectedDoctor,
                  hint: Text(
                    SettingsStrings.selectDoctor,
                    style: AppStyles.bodyMedium,
                  ),
                  isExpanded: true,
                  items: widget.doctors.map((doctor) {
                    return DropdownMenuItem(
                      value: doctor,
                      child: Text(
                        '${doctor.name} - ${doctor.specialization}',
                        style: AppStyles.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDoctor = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _shareNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  SettingsStrings.shareNote,
                  style: AppStyles.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved successfully')),
    );
  }

  void _shareNote() {
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note shared with ${_selectedDoctor!.name}'),
      ),
    );
  }
}
