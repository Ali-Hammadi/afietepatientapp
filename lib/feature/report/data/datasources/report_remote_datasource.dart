import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/report/data/models/app_report_model.dart';
import 'package:afiete/feature/report/data/models/report_config_model.dart';
import 'package:afiete/feature/report/data/models/user_report_model.dart';
import 'package:dio/dio.dart';

abstract class ReportsRemoteDataSource {
  Future<ReportConfigModel> getReportConfig();
  Future<Map<String, List<dynamic>>> getMyReports();
  Future<void> createAppReport({
    required String reason,
    required String description,
  });
  Future<void> createUserReport({
    required String reportType,
    required String targetName,
    required String reason,
    required String description,
  });
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Dio dio;

  ReportsRemoteDataSourceImpl({required this.dio});

  @override
  Future<ReportConfigModel> getReportConfig() async {
    final response = await dio.get(ApiEndpoints.reportsConfig);
    return ReportConfigModel.fromJson(response.data);
  }

  @override
  Future<Map<String, List<dynamic>>> getMyReports() async {
    final response = await dio.get(ApiEndpoints.myReports);
    final appReports = (response.data['app_reports'] as List)
        .map((e) => AppReportModel.fromJson(e))
        .toList();
    final userReports = (response.data['user_reports'] as List)
        .map((e) => UserReportModel.fromJson(e))
        .toList();
    return {
      "app_reports": appReports,
      "user_reports": userReports,
    };
  }

  @override
  Future<void> createAppReport({
    required String reason,
    required String description,
  }) async {
    await dio.post(
      ApiEndpoints.appReports,
      data: {
        "reason": reason,
        "description": description,
      },
    );
  }

  @override
  Future<void> createUserReport({
    required String reportType,
    required String targetName,
    required String reason,
    required String description,
  }) async {
    await dio.post(
      ApiEndpoints.reportOnUser,
      data: {
        "reportType": reportType,
        "targetName": targetName,
        "reason": reason,
        "description": description,
      },
    );
  }
}
