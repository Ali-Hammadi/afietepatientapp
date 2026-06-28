// feature/settings/data/data_source/settings_remote_data_source.dart
import 'package:afiete/feature/settings/data/models/medical_profile_model.dart';
import 'package:dio/dio.dart';

abstract class SettingsRemoteDataSource {
  Future<MedicalProfileModel> getMedicalProfile(String userId);
  Future<String> submitReportIssue({
    required String userId,
    required String reason,
    required String details,
  });
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio dio;

  SettingsRemoteDataSourceImpl({required this.dio});

  @override
  Future<MedicalProfileModel> getMedicalProfile(String userId) async {
    try {
      // TODO: Add your endpoint here
      final response = await dio.get('/users/$userId/medical-profile');

      if (response.data is Map<String, dynamic>) {
        return MedicalProfileModel.fromJson(
            response.data as Map<String, dynamic>);
      }

      return const MedicalProfileModel(
        prescriptions: [],
        notes: [],
      );
    } on DioException catch (e) {
      throw Exception('Failed to get medical profile: ${e.message}');
    }
  }

  @override
  Future<String> submitReportIssue({
    required String userId,
    required String reason,
    required String details,
  }) async {
    try {
      // TODO: Add your endpoint here
      await dio.post(
        '/reports',
        data: {
          'user_id': userId,
          'reason': reason,
          'details': details,
        },
      );

      return 'Report submitted successfully';
    } on DioException catch (e) {
      throw Exception('Failed to submit report: ${e.message}');
    }
  }
}
