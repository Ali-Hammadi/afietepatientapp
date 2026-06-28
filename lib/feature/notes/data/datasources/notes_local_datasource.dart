// feature/notes/data/datasources/note_local_datasource.dart
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/notes/data/models/notes_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class NoteLocalDataSource {
  Future<List<MedicalNoteModel>> getNotes();
  Future<void> saveNote(MedicalNoteModel note);
  Future<void> updateNote(MedicalNoteModel note);
  Future<void> deleteNote(String noteId);
  Future<void> syncNotes(List<MedicalNoteModel> notes);
  Future<List<DoctorEntity>> getRegisteredDoctors();
  Future<void> saveRegisteredDoctors(List<DoctorEntity> doctors);
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String NOTES_KEY = 'medical_notes';
  static const String DOCTORS_KEY = 'registered_doctors';

  NoteLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<MedicalNoteModel>> getNotes() async {
    final notesJson = sharedPreferences.getString(NOTES_KEY);
    if (notesJson == null) return [];

    final List<dynamic> notesList = json.decode(notesJson);
    return notesList
        .map((j) => MedicalNoteModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveNote(MedicalNoteModel note) async {
    final notes = await getNotes();
    notes.add(note);
    await _saveNotesList(notes);
  }

  @override
  Future<void> updateNote(MedicalNoteModel note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    await _saveNotesList(notes);
  }

  @override
  Future<void> deleteNote(String noteId) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == noteId);
    await _saveNotesList(notes);
  }

  // ✅ مزامنة كاملة للقائمة مع الـ local storage
  @override
  Future<void> syncNotes(List<MedicalNoteModel> notes) async {
    await _saveNotesList(notes);
  }

  @override
  Future<List<DoctorEntity>> getRegisteredDoctors() async {
    final doctorsJson = sharedPreferences.getString(DOCTORS_KEY);
    if (doctorsJson == null) return [];

    final List<dynamic> doctorsList = json.decode(doctorsJson);
    return doctorsList
        .map((j) => _doctorFromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveRegisteredDoctors(List<DoctorEntity> doctors) async {
    final doctorsJson = json.encode(
      doctors.map((d) => _doctorToJson(d)).toList(),
    );
    await sharedPreferences.setString(DOCTORS_KEY, doctorsJson);
  }

  Future<void> _saveNotesList(List<MedicalNoteModel> notes) async {
    final notesJson = json.encode(notes.map((n) => n.toJson()).toList());
    await sharedPreferences.setString(NOTES_KEY, notesJson);
  }

  Map<String, dynamic> _doctorToJson(DoctorEntity doctor) {
    return {
      'doctorUsername': doctor.doctorUsername,
      'name': doctor.name,
      'specialties': doctor.specialties,
      'imageUrl': doctor.imageUrl,
      'jobTitle': doctor.jobTitle,
      'experienceYears': doctor.experienceYears,
      'bio': doctor.bio,
    };
  }

  DoctorEntity _doctorFromJson(Map<String, dynamic> json) {
    return DoctorEntity(
      doctorUsername: json['doctorUsername'] as String? ?? '',
      name: json['name'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['imageUrl'] as String?,
      jobTitle: json['jobTitle'] as String?,
      experienceYears: json['experienceYears'] as int?,
      bio: json['bio'] as String?,
    );
  }
}
