import 'package:afiete/feature/report/domain/entities/report_config.dart';
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
              userReports: reportsMap['user_reports'] as List<UserReport>,
            ));
          },
        );
      },
    );
  }

  Future<void> submitAppReport({
    required String reason,
    required String description,
  }) async {
    emit(const ReportActionLoading());

    final result = await createAppReportUseCase(
      reason: reason,
      description: description,
    );

    result.fold(
      (failure) => emit(ReportsError(failure.errorMessage)),
      (_) => emit(const ReportSubmitSuccess(
          "تم إرسال البلاغ التقني بنجاح وسيتم مراجعته.")),
    );
  }

  Future<void> submitUserReport({
    required String reportType,
    required String targetName,
    required String reason,
    required String description,
  }) async {
    emit(const ReportActionLoading());

    final result = await createUserReportUseCase(
      reportType: reportType,
      targetName: targetName,
      reason: reason,
      description: description,
    );

    result.fold(
      (failure) => emit(ReportsError(failure.errorMessage)),
      (_) => emit(const ReportSubmitSuccess(
          "تم إرسال البلاغ ضد المستخدم بنجاح وسيتم مراجعته.")),
    );
  }
}
