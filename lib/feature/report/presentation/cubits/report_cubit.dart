import 'package:afiete/feature/report/data/config/report_config.dart';
import 'package:afiete/feature/report/data/models/user_report_model.dart';
import 'package:afiete/feature/report/domain/entities/report_entity.dart';
import 'package:afiete/feature/report/domain/usecases/report_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final GetReportConfigUseCase getReportConfigUseCase;
  final GetMyReportsUseCase getMyReportsUseCase;
  final CreateAppReportUseCase createAppReportUseCase;
  final CreateUserReportUseCase createUserReportUseCase;
  ReportCubit({
    required this.getReportConfigUseCase,
    required this.getMyReportsUseCase,
    required this.createAppReportUseCase,
    required this.createUserReportUseCase,
  }) : super(const ReportInitial());

  /// جلب لوحة تحكم التقارير بالكامل (الأسباب المتاحة + سجل المستخدم الحالي)
  Future<void> loadReportsDashboard() async {
    emit(const ReportsDashboardLoading());

    final configResult = await getReportConfigUseCase();
    final reportsResult = await getMyReportsUseCase();

    configResult.fold(
      (failure) => emit(ReportsError(failure.errorMessage)),
      (config) {
        reportsResult.fold(
          (failure) => emit(ReportsError(failure.errorMessage)),
          (reportsMap) {
            emit(ReportsDashboardLoaded(
              config: config,
              appReports: reportsMap['app_reports'] as List<AppReport>,
              userReports: reportsMap['user_reports'] as List<UserReportModel>,
            ));
          },
        );
      },
    );
  }

  /// إنشاء بلاغ تقني أو اقتراح للتطبيق
  Future<void> submitAppReport({
    required String reportType,
    required String title,
    required String content,
  }) async {
    emit(const ReportActionLoading());

    final result = await createAppReportUseCase(
      reportType: reportType,
      title: title,
      content: content,
    );

    result.fold(
      (failure) => emit(ReportsError(failure.errorMessage)),
      (_) => emit(const ReportSubmitSuccess(
          "Your report has been submitted successfully and will be reviewed.")),
    );
  }

  /// إنشاء بلاغ ضد مستخدم (طبيب/مريض) - سيتحقق السيرفر تلقائياً من الجلسة المشتركة
  Future<void> submitUserReport({
    required String reportedUsername,
    required String content,
  }) async {
    emit(const ReportActionLoading());

    final result = await createUserReportUseCase(
      reportedUsername: reportedUsername,
      content: content,
    );

    result.fold(
      (failure) => emit(ReportsError(failure.errorMessage)),
      (_) => emit(const ReportSubmitSuccess(
          "Your report against the user has been submitted successfully and will be reviewed.")),
    );
  }
}
