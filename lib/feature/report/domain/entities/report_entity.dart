import 'package:equatable/equatable.dart';

class AppReport extends Equatable {
  final int id;
  final String reportType;
  final String reportTypeDisplay;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isResolved;

  const AppReport({
    required this.id,
    required this.reportType,
    required this.reportTypeDisplay,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isResolved,
  });

  @override
  List<Object?> get props => [id, reportType, title, content, isResolved];
}

class UserReport extends Equatable {
  final int id;
  final int? reportedUser;
  final String reportedUsername;
  final String content;
  final DateTime createdAt;
  final String actionTaken;

  const UserReport({
    required this.id,
    this.reportedUser,
    required this.reportedUsername,
    required this.content,
    required this.createdAt,
    required this.actionTaken,
  });

  @override
  List<Object?> get props =>
      [id, reportedUser, reportedUsername, content, actionTaken];
}
