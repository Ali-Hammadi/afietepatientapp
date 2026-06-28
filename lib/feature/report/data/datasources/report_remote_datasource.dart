import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/report/data/models/user_report_model.dart';
import 'package:dio/dio.dart';
import '../models/app_report_model.dart';
import '../models/report_config_model.dart';

abstract class ReportsRemoteDataSource {
  Future<ReportConfigModel> getReportConfig();
  Future<Map<String, List<dynamic>>> getMyReports();
  void createAppReport(String type, String title, String content);
  void createUserReport(String targetUserId, String content);
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Dio dio; // يتم تمرير الـ Dio المحقون مع الـ Token المحدث بـ Interceptor
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
    return {"app_reports": appReports, "user_reports": userReports};
  }

  @override
  Future<void> createAppReport(
      String type, String title, String content) async {
    await dio.post(ApiEndpoints.appReports, data: {
      "report_type": type,
      "title": title,
      "content": content,
    });
  }

  @override
  Future<void> createUserReport(String targetUsername, String content) async {
    await dio.post(ApiEndpoints.reportOnUser, data: {
      "reported_user": targetUsername,
      "content": content,
    });
  }
}
