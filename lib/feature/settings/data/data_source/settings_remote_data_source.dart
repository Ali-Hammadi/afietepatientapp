// feature/settings/data/data_source/settings_remote_data_source.dart
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

abstract class SettingsRemoteDataSource {
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
  Future<String> submitReportIssue({
    required String userId,
    required String reason,
    required String details,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.appReports,
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
