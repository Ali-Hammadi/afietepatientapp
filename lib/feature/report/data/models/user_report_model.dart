import 'package:afiete/feature/report/domain/entities/report_entity.dart';

class UserReportModel extends UserReport {
  const UserReportModel({
    required super.id,
    required super.reportType,
    super.targetId,
    super.targetName,
    required super.reason,
    required super.description,
    required super.status,
    required super.actionTaken,
    required super.createdAt,
    super.resolvedAt,
  });

  factory UserReportModel.fromJson(Map<String, dynamic> json) {
    return UserReportModel(
      id: json['id'],
      reportType: json['reportType'] ?? 'doctor',
      targetId: json['targetId'],
      targetName: json['targetName'],
      reason: json['reason'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      actionTaken: json['action_taken'] ?? 'NONE',
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
      'targetId': targetId,
      'targetName': targetName,
      'reason': reason,
      'description': description,
      'status': status,
      'action_taken': actionTaken,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
}
