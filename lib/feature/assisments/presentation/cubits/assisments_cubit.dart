import 'package:afiete/core/constants/psychology_specialties.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/assisments/data/assisment_visibility_store.dart';
import 'package:afiete/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assisments/domain/usecase/get_assisment_questions_usecase.dart';
import 'package:afiete/feature/assisments/domain/usecase/submit_assisment_usecase.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'assisments_state.dart';

class AssismentsCubit extends Cubit<AssismentsState> {
  final GetAssismentQuestionsUseCase getAssismentQuestionsUseCase;
  final SubmitAssismentUseCase submitAssismentUseCase;
  final GetAllDoctorsUseCase getAllDoctorsUseCase;
  final GetDoctorsBySpecialtyUseCase getDoctorsBySpecialtyUseCase;

  AssismentsCubit(
    this.getAssismentQuestionsUseCase,
    this.submitAssismentUseCase,
    this.getAllDoctorsUseCase,
    this.getDoctorsBySpecialtyUseCase,
  ) : super(const AssismentsInitial());

  Future<void> loadQuestions() async {
    emit(const AssismentsLoading());
    final result = await getAssismentQuestionsUseCase(NoParams());

    result.fold((failure) => emit(AssismentsError(failure.errorMessage)), (
      questions,
    ) {
      if (questions.isEmpty) {
        emit(AssismentsError(SettingsStrings.assessmentNoQuestionsAvailable));
        return;
      }

      emit(
        AssismentsLoaded(
          questions: questions,
          selectedAnswers: const {},
          currentQuestionIndex: 0,
        ),
      );
    });
  }

  void selectAnswer({required int questionId, required int answerId}) {
    final currentState = state;
    if (currentState is! AssismentsLoaded) {
      return;
    }

    final updatedAnswers = Map<int, int>.from(currentState.selectedAnswers)
      ..[questionId] = answerId;

    emit(
      currentState.copyWith(
        selectedAnswers: updatedAnswers,
        validationError: null,
      ),
    );
  }

  void goToNextQuestion() {
    final currentState = state;
    if (currentState is! AssismentsLoaded) {
      return;
    }

    final currentQuestion = currentState.currentQuestion;
    if (currentQuestion == null) {
      emit(AssismentsError(SettingsStrings.assessmentNoQuestionsAvailable));
      return;
    }

    final currentQuestionId = currentQuestion.id;
    final currentAnswer = currentState.selectedAnswers[currentQuestionId];
    if (currentAnswer == null) {
      emit(
        currentState.copyWith(
          validationError: SettingsStrings.chooseAnswerBeforeContinuing,
        ),
      );
      return;
    }

    if (currentState.currentQuestionIndex >=
        currentState.questions.length - 1) {
      return;
    }

    emit(
      currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
        validationError: null,
      ),
    );
  }

  void goToPreviousQuestion() {
    final currentState = state;
    if (currentState is! AssismentsLoaded) {
      return;
    }

    if (currentState.currentQuestionIndex <= 0) {
      return;
    }

    emit(
      currentState.copyWith(
        currentQuestionIndex: currentState.currentQuestionIndex - 1,
        validationError: null,
      ),
    );
  }

  Future<void> submitCurrentAssisment() async {
    final currentState = state;
    if (currentState is! AssismentsLoaded) {
      return;
    }

    final currentQuestion = currentState.currentQuestion;
    if (currentQuestion == null) {
      emit(AssismentsError(SettingsStrings.assessmentNoQuestionsAvailable));
      return;
    }

    if (currentState.selectedAnswers.length != currentState.questions.length) {
      emit(
        currentState.copyWith(
          validationError: SettingsStrings.answerAllQuestionsBeforeSubmitting,
        ),
      );
      return;
    }

    final answers = currentState.selectedAnswers.entries
        .map(
          (entry) => AssismentEntity.answer(
            questionId: entry.key,
            selectedOptionId: entry.value,
          ),
        )
        .toList();

    emit(const AssismentsSubmitting());

    final submissionResult = await submitAssismentUseCase(
      SubmitAssismentParams(answers: answers),
    );

    await submissionResult.fold(
      (failure) async => emit(AssismentsError(failure.errorMessage)),
      (result) async {
        await AssismentVisibilityStore.markAssismentCompleted();
        final doctors = await _resolveRecommendedDoctors(result);
        emit(AssismentsResultLoaded(result: result, doctors: doctors));
      },
    );
  }

  Future<List<DoctorEntity>> _resolveRecommendedDoctors(
    AssismentEntity result,
  ) async {
    final Map<String, DoctorEntity> uniqueDoctors = {};

    if (result.recommendedDoctorIds.isNotEmpty) {
      final allDoctorsResult = await getAllDoctorsUseCase(NoParams());
      allDoctorsResult.fold((_) {}, (doctors) {
        for (final doctor in doctors) {
          if (result.recommendedDoctorIds.contains(doctor.id)) {
            uniqueDoctors[doctor.id] = doctor;
          }
        }
      });
    }

    final specialties = result.recommendedSpecialties.isNotEmpty
        ? result.recommendedSpecialties
        : [_severityFallbackSpecialty(result.severity)];

    for (final specialty in specialties) {
      final doctorsResult = await getDoctorsBySpecialtyUseCase(
        GetDoctorsBySpecialtyParams(specialty: specialty),
      );

      doctorsResult.fold((_) {}, (doctors) {
        for (final doctor in doctors) {
          uniqueDoctors[doctor.id] = doctor;
        }
      });
    }

    return uniqueDoctors.values.toList();
  }

  String _severityFallbackSpecialty(String severity) {
    final normalized = severity.toLowerCase();

    if (normalized.contains('severe') || normalized.contains('high')) {
      return PsychologySpecialties.psychiatrist;
    }

    if (normalized.contains('moderate') || normalized.contains('medium')) {
      return PsychologySpecialties.clinicalPsychologist;
    }

    return PsychologySpecialties.counselor;
  }

  Future<void> retakeAssisment() async {
    await loadQuestions();
  }
}
