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

  /// جلب لوحة تحكم التقارير بالكامل
  Future<void> loadReportsDashboard() async {
    // ✅ التحقق من عدم إغلاق الـ Cubit قبل البدء
    if (isClosed) return;
    emit(const ReportsDashboardLoading());

    final configResult = await getReportConfigUseCase();

    // ✅ التحقق بعد كل عملية async
    if (isClosed) return;

    final reportsResult = await getMyReportsUseCase();
    if (isClosed) return;

    configResult.fold(
      (failure) {
        if (!isClosed) emit(ReportsError(failure.errorMessage));
      },
      (config) {
        reportsResult.fold(
          (failure) {
            if (!isClosed) emit(ReportsError(failure.errorMessage));
          },
          (reportsMap) {
            if (!isClosed) {
              emit(ReportsDashboardLoaded(
                config: config,
                appReports: reportsMap['app_reports'] as List<AppReport>,
                userReports: reportsMap['user_reports'] as List<UserReport>,
              ));
            }
          },
        );
      },
    );
  }

  /// إنشاء بلاغ تقني أو اقتراح للتطبيق
  Future<void> submitAppReport({
    required String reason,
    required String description,
  }) async {
    if (isClosed) return;
    emit(const ReportActionLoading());

    final result = await createAppReportUseCase(
      reason: reason,
      description: description,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) emit(ReportsError(failure.errorMessage));
      },
      (_) {
        if (!isClosed) {
          emit(const ReportSubmitSuccess(
              "تم إرسال البلاغ التقني بنجاح وسيتم مراجعته."));
        }
      },
    );
  }

  /// إنشاء بلاغ ضد مستخدم آخر
  Future<void> submitUserReport({
    required String reportType,
    required String targetName,
    required String reason,
    required String description,
  }) async {
    if (isClosed) return;
    emit(const ReportActionLoading());

    final result = await createUserReportUseCase(
      reportType: reportType,
      targetName: targetName,
      reason: reason,
      description: description,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) emit(ReportsError(failure.errorMessage));
      },
      (_) {
        if (!isClosed) {
          emit(const ReportSubmitSuccess(
              "تم إرسال البلاغ ضد المستخدم بنجاح وسيتم مراجعته."));
        }
      },
    );
  }
}
