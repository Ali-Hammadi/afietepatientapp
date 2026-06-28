// feature/notes/data/datasources/note_remote_datasource.dart
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/notes/data/models/notes_model.dart';
import 'package:dio/dio.dart';

abstract class NoteRemoteDataSource {
  Future<MedicalNoteModel> createNote(MedicalNoteModel note);
  Future<MedicalNoteModel> updateNote(MedicalNoteModel note);
  Future<void> deleteNote(String noteId);
  Future<List<MedicalNoteModel>> getNotes();
  Future<List<DoctorEntity>> getRegisteredDoctors();
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final Dio dio;

  NoteRemoteDataSourceImpl({required this.dio});

  // ✅ Create: POST /api/patient/notes/
  @override
  Future<MedicalNoteModel> createNote(MedicalNoteModel note) async {
    try {
      final response = await dio.post(
        '/api/patient/notes/',
        data: note.toJson(),
      );

      if (response.statusCode == 201 && response.data is Map<String, dynamic>) {
        return MedicalNoteModel.fromJson(response.data as Map<String, dynamic>);
      }
      return note;
    } on DioException catch (e) {
      throw Exception(
          'Failed to create note: ${e.response?.data ?? e.message}');
    }
  }

  // ✅ Update: PUT /api/patient/notes/{id}/
  // (ModelViewSet يدعم PUT تلقائياً)
  @override
  Future<MedicalNoteModel> updateNote(MedicalNoteModel note) async {
    if (note.id == null) {
      throw Exception('Cannot update note without id');
    }

    try {
      final response = await dio.put(
        '/api/patient/notes/${note.id}/',
        data: note.toJson(),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return MedicalNoteModel.fromJson(response.data as Map<String, dynamic>);
      }
      return note;
    } on DioException catch (e) {
      throw Exception(
          'Failed to update note: ${e.response?.data ?? e.message}');
    }
  }

  // ✅ Delete: DELETE /api/patient/notes/{id}/
  @override
  Future<void> deleteNote(String noteId) async {
    try {
      await dio.delete('/api/patient/notes/$noteId/');
    } on DioException catch (e) {
      throw Exception(
          'Failed to delete note: ${e.response?.data ?? e.message}');
    }
  }

  // ✅ List: GET /api/patient/notes/
  @override
  Future<List<MedicalNoteModel>> getNotes() async {
    try {
      final response = await dio.get('/api/patient/notes/');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) =>
                  MedicalNoteModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // إذا السيرفر يرجع paginated response
        if (response.data is Map && response.data['results'] is List) {
          return (response.data['results'] as List)
              .map((json) =>
                  MedicalNoteModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to get notes: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<DoctorEntity>> getRegisteredDoctors() async {
    try {
      final response = await dio.get('/api/patient/doctors/');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> doctorsList;

        if (data is List) {
          doctorsList = data;
        } else if (data is Map && data['results'] is List) {
          doctorsList = data['results'] as List;
        } else {
          doctorsList = [];
        }

        return doctorsList
            .map((json) => _parseDoctor(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          'Failed to get doctors: ${e.response?.data ?? e.message}');
    }
  }

  DoctorEntity _parseDoctor(Map<String, dynamic> json) {
    final userMap = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;

    final username = json['username']?.toString() ??
        json['doctor_username']?.toString() ??
        userMap?['username']?.toString() ??
        '';

    String name = json['name']?.toString() ?? '';
    if (name.isEmpty && userMap != null) {
      final firstName = userMap['first_name']?.toString() ?? '';
      final lastName = userMap['last_name']?.toString() ?? '';
      name = '$firstName $lastName'.trim();
    }
    if (name.isEmpty) name = username;

    final rawSpecialties = json['specialties'] as List?;
    final List<String> specialtiesList = [];
    if (rawSpecialties != null) {
      for (final item in rawSpecialties) {
        if (item is Map<String, dynamic>) {
          final sName = item['name']?.toString();
          if (sName != null && sName.isNotEmpty) {
            specialtiesList.add(sName);
          }
        } else {
          final sStr = item?.toString();
          if (sStr != null && sStr.isNotEmpty) {
            specialtiesList.add(sStr);
          }
        }
      }
    }

    return DoctorEntity(
      doctorUsername: username,
      name: name,
      specialties: specialtiesList,
      bio: json['bio']?.toString() ?? json['description']?.toString(),
      imageUrl: json['image_path']?.toString() ?? json['photo']?.toString(),
      jobTitle: json['job_title'] is Map<String, dynamic>
          ? (json['job_title'] as Map<String, dynamic>)['title']?.toString()
          : json['job_title']?.toString(),
      experienceYears: json['experience'] is int
          ? json['experience'] as int
          : int.tryParse(json['experience']?.toString() ?? ''),
    );
  }
}
