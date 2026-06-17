import 'package:afiete/feature/report/domain/entities/report_entity.dart';

class UserReportModel extends AppReport {
  const UserReportModel({
    required super.id,
    required super.reportType,
    required super.reportTypeDisplay,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.isResolved,
  });

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    return UserReportModel(
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
