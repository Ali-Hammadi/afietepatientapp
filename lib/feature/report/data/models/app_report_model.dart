import 'package:afiete/feature/report/domain/entities/report_entity.dart';

class AppReportModel extends AppReport {
  const AppReportModel({
    required super.id,
    required super.reportType,
    required super.reportTypeDisplay,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.isResolved,
  });

  factory AppReportModel.fromJson(Map<String, dynamic> json) {
    return AppReportModel(
      id: json['id'],
      reportType: json['report_type'] ?? '',
      reportTypeDisplay: json['report_type_display'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      isResolved: json['is_resolved'] ?? false,
    );
  }
}
