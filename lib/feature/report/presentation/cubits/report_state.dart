part of 'report_cubit.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

// حالة تحميل لوحة التحكم بالبلاغات (الإعدادات + السجل السلوكي والتقني)
class ReportsDashboardLoading extends ReportState {
  const ReportsDashboardLoading();
}

class ReportsDashboardLoaded extends ReportState {
  final ReportConfig config;
  final List<AppReport> appReports;
  final List<UserReport> userReports;

  const ReportsDashboardLoaded({
    required this.config,
    required this.appReports,
    required this.userReports,
  });

  @override
  List<Object?> get props => [config, appReports, userReports];
}

// حالات معالجة إرسال بلاغ جديد (سواء كان تطبيق أو يوزر)
class ReportActionLoading extends ReportState {
  const ReportActionLoading();
}

class ReportSubmitSuccess extends ReportState {
  final String message;

  const ReportSubmitSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// حالة الأخطاء الموحدة (تشمل أخطاء السيرفر مثل غياب الجلسة المشتركة)
class ReportsError extends ReportState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
