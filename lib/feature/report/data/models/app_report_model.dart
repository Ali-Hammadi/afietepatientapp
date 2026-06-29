import 'package:afiete/feature/report/domain/entities/report_entity.dart';

class AppReportModel extends AppReport {
  const AppReportModel({
    required super.id,
    required super.reportType,
    required super.reason,
    required super.description,
    required super.status,
    required super.createdAt,
    super.resolvedAt,
  });

  factory AppReportModel.fromJson(Map<String, dynamic> json) {
    return AppReportModel(
      id: json['id'],
      reportType: json['reportType'] ?? 'app',
      reason: json['reason'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportType': reportType,
      'reason': reason,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
}
