import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/usecases/usecase.dart';
import 'package:afiete/feature/assessments/data/assisment_visibility_store.dart';
import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assessments/domain/usecase/get_assessment_scores_usecase.dart';
import 'package:afiete/feature/assessments/domain/usecase/get_assisment_questions_usecase.dart';
import 'package:afiete/feature/assessments/domain/usecase/submit_assisment_usecase.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_state.dart';

import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/domain/usecase/get_doctors_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssessmentsCubit extends Cubit<AssessmentsState> {
  final GetAssessmentsQuestionsUseCase getAssessmentsQuestionsUseCase;
  final SubmitAssessmentsUseCase submitAssessmentsUseCase;
  final GetAllDoctorsUseCase getAllDoctorsUseCase;
  final GetDoctorsBySpecialtyUseCase getDoctorsBySpecialtyUseCase;
  final GetAssessmentScoresUseCase getAssessmentScoresUseCase;

  AssessmentsCubit(
    this.getAssessmentsQuestionsUseCase,
    this.submitAssessmentsUseCase,
    this.getAllDoctorsUseCase,
    this.getDoctorsBySpecialtyUseCase,
    this.getAssessmentScoresUseCase,
  ) : super(const AssessmentsInitial());

  Future<void> loadQuestions() async {
    emit(const AssessmentsLoading());
    final result = await getAssessmentsQuestionsUseCase(NoParams());

    result.fold((failure) => emit(AssessmentsError(failure.errorMessage)), (
      questions,
    ) {
      if (questions.isEmpty) {
        emit(AssessmentsError(SettingsStrings.assessmentNoQuestionsAvailable));
        return;
      }

      emit(
        AssessmentsLoaded(
          questions: questions,
          selectedAnswers: const {},
          currentQuestionIndex: 0,
        ),
      );
    });
  }

  void selectAnswer({required int questionId, required int answerId}) {
    final currentState = state;
    if (currentState is! AssessmentsLoaded) {
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
    if (currentState is! AssessmentsLoaded) {
      return;
    }

    final currentQuestion = currentState.currentQuestion;
    if (currentQuestion == null) {
      emit(AssessmentsError(SettingsStrings.assessmentNoQuestionsAvailable));
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
    if (currentState is! AssessmentsLoaded) {
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

  Future<void> submitCurrentAssessments() async {
    final currentState = state;
    if (currentState is! AssessmentsLoaded) {
      return;
    }

    final currentQuestion = currentState.currentQuestion;
    if (currentQuestion == null) {
      emit(AssessmentsError(SettingsStrings.assessmentNoQuestionsAvailable));
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
          (entry) => AssessmentsEntity.answer(
            questionId: entry.key,
            selectedOptionId: entry.value,
          ),
        )
        .toList();

    emit(const AssessmentsSubmitting());

    final submissionResult = await submitAssessmentsUseCase(
      SubmitAssessmentsParams(answers: answers),
    );

    await submissionResult.fold(
      (failure) async => emit(AssessmentsError(failure.errorMessage)),
      (result) async {
        await AssessmentsVisibilityStore.markAssessmentsCompleted();
        final doctors = await _resolveRecommendedDoctors(result);
        emit(AssessmentsResultLoaded(result: result, doctors: doctors));
      },
    );
  }

  Future<List<DoctorEntity>> _resolveRecommendedDoctors(
    AssessmentsEntity result,
  ) async {
    final Map<String, DoctorEntity> uniqueDoctors = {};

    if (result.recommendedDoctorUsrnames.isNotEmpty) {
      final allDoctorsResult = await getAllDoctorsUseCase(NoParams());
      allDoctorsResult.fold((_) {}, (doctors) {
        for (final doctor in doctors) {
          if (result.recommendedDoctorUsrnames
              .contains(doctor.doctorUsername)) {
            uniqueDoctors[doctor.doctorUsername] = doctor;
          }
        }
      });
    }

    final specialties = result.recommendedSpecialties.isNotEmpty
        ? result.recommendedSpecialties
        : [_severityFallbackSpecialty(result.severity)];

    for (final specialty in specialties) {
      // ✅ معالجة آمنة للنصوص لمنع FormatException
      final int? specialtyId = int.tryParse(specialty);

      if (specialtyId == null) {
        // إذا كان التخصص المرتجع عبارة عن نص (مثل اسم التخصص) وليس معرف رقمي
        continue;
      }

      final doctorsResult = await getDoctorsBySpecialtyUseCase(
        GetDoctorsBySpecialtyParams(specialtyId: specialtyId),
      );

      doctorsResult.fold((_) {}, (doctors) {
        for (final doctor in doctors) {
          uniqueDoctors[doctor.doctorUsername] = doctor;
        }
      });
    }

    return uniqueDoctors.values.toList();
  }

  // ✅ تعديل الدالة لتعود بـ IDs نصية تطابق تخصصات قاعدة البيانات بدلاً من الكلمات الإنجليزية الثابتة
  String _severityFallbackSpecialty(String severity) {
    final normalized = severity.toLowerCase();

    // ملاحظة: تأكد من مطابقة أرقام الـ IDs ('1', '2', '3') مع معرفات التخصصات الفعلية في Django لديك
    if (normalized.contains('severe') || normalized.contains('high')) {
      return '1'; // مثلاً: ID طبيب نفسي (Psychiatrist)
    }

    if (normalized.contains('moderate') || normalized.contains('medium')) {
      return '2'; // مثلاً: ID أخصائي نفسي عيادي (Clinical Psychologist)
    }

    return '3'; // مثلاً: ID مستشار نفسي (Counselor)
  }

  Future<void> loadLastScores() async {
    emit(const AssessmentsLoading());
    final result = await getAssessmentScoresUseCase(NoParams());
    result.fold(
      (failure) => emit(AssessmentsError(failure.errorMessage)),
      (scores) => emit(AssessmentsLastScoresLoaded(scores: scores)),
    );
  }

  Future<void> retakeAssessments() async {
    await loadQuestions();
  }
}
