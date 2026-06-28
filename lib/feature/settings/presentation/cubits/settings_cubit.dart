// feature/settings/presentation/cubits/settings_cubit.dart
import 'package:afiete/feature/settings/domin/entities/medical_profile_entity.dart';
import 'package:afiete/feature/settings/domin/usecase/get_medical_profile_usecase.dart';
import 'package:afiete/feature/settings/domin/usecase/submit_report_issue_usecase.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final GetMedicalProfileUseCase getMedicalProfileUseCase;
  final SubmitReportIssueUseCase submitReportIssueUseCase;

  SettingsCubit(
    this.getMedicalProfileUseCase,
    this.submitReportIssueUseCase,
  ) : super(const SettingsInitial());

  MedicalProfileEntity? _currentProfile;
  MedicalProfileEntity? get currentProfile => _currentProfile;

  Future<void> loadMedicalProfile(String userId) async {
    final safeUserId = userId.isEmpty ? 'mock-user' : userId;

    emit(const SettingsLoading());
    final result = await getMedicalProfileUseCase(safeUserId);
    result.fold(
      (failure) => emit(SettingsError(failure.errorMessage)),
      (profile) {
        _currentProfile = profile;
        emit(SettingsLoaded(profile));
      },
    );
  }

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
