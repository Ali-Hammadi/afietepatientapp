import 'package:equatable/equatable.dart';

class AppReport extends Equatable {
  final int id;
  final String reportType; // 'app'
  final String reason; // 'appBug', 'crashOrFreeze', 'paymentIssue', 'other'
  final String description;
  final String status; // 'pending', 'reviewed', 'resolved'
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const AppReport({
    required this.id,
    required this.reportType,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  bool get isResolved => status == 'resolved';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
        id,
        reportType,
        reason,
        description,
        status,
        createdAt,
        resolvedAt,
      ];
}

class UserReport extends Equatable {
  final int id;
  final String reportType; // 'doctor' or 'session'
  final String? targetId;
  final String? targetName;
  final String reason; // 'unprofessional', 'harassment', etc.
  final String description;
  final String status; // 'pending', 'reviewed', 'resolved'
  final String actionTaken; // 'NONE', 'FUNDS_FROZEN', etc.
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const UserReport({
    required this.id,
    required this.reportType,
    this.targetId,
    this.targetName,
    required this.reason,
    required this.description,
    required this.status,
    required this.actionTaken,
    required this.createdAt,
    this.resolvedAt,
  });

  bool get isResolved => status == 'resolved';
  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
        id,
        reportType,
        targetId,
        targetName,
        reason,
        description,
        status,
        actionTaken,
        createdAt,
        resolvedAt,
      ];
}
