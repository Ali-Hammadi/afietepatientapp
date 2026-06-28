// feature/settings/presentation/cubits/settings_cubit.dart
import 'package:afiete/feature/settings/domin/usecase/submit_report_issue_usecase.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SubmitReportIssueUseCase submitReportIssueUseCase;

  SettingsCubit(
    this.submitReportIssueUseCase,
  ) : super(const SettingsInitial());

  Future<void> submitReportIssue({
    required String userId,
    required String reason,
    required String details,
  }) async {
    if (userId.isEmpty) {
      emit(SettingsError(SettingsStrings.missingUserInformation));
      return;
    }

    emit(const SettingsSubmittingReport());
    final result = await submitReportIssueUseCase(
      SubmitReportIssueParams(
        userId: userId,
        reason: reason,
        details: details,
      ),
    );
    result.fold(
      (failure) => emit(SettingsError(failure.errorMessage)),
      (_) => emit(
        SettingsReportSubmitted(SettingsStrings.reportSubmittedSuccessfully),
      ),
    );
  }
}
