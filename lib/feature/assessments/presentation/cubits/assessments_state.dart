import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AssessmentsState extends Equatable {
  const AssessmentsState();

  @override
  List<Object?> get props => [];
}

class AssessmentsInitial extends AssessmentsState {
  const AssessmentsInitial();
}

class AssessmentsLoading extends AssessmentsState {
  const AssessmentsLoading();
}

class AssessmentsLoaded extends AssessmentsState {
  final List<AssessmentsEntity> questions;
  final Map<int, int> selectedAnswers;
  final int currentQuestionIndex;
  final String? validationError;

  const AssessmentsLoaded({
    required this.questions,
    required this.selectedAnswers,
    required this.currentQuestionIndex,
    this.validationError,
  });

  bool get hasQuestions => questions.isNotEmpty;

  AssessmentsEntity? get currentQuestion =>
      hasQuestions ? questions[currentQuestionIndex] : null;

  AssessmentsLoaded copyWith({
    List<AssessmentsEntity>? questions,
    Map<int, int>? selectedAnswers,
    int? currentQuestionIndex,
    String? validationError,
  }) {
    return AssessmentsLoaded(
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      validationError: validationError,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        selectedAnswers,
        currentQuestionIndex,
        validationError,
      ];
}

class AssessmentsSubmitting extends AssessmentsState {
  const AssessmentsSubmitting();
}

class AssessmentsResultLoaded extends AssessmentsState {
  final AssessmentsEntity result;
  final List<DoctorEntity> doctors;

  const AssessmentsResultLoaded({required this.result, required this.doctors});

  @override
  List<Object?> get props => [result, doctors];
}

class AssessmentsLastScoresLoaded extends AssessmentsState {
  final List<AssessmentScoreEntry> scores;

  const AssessmentsLastScoresLoaded({required this.scores});

  @override
  List<Object?> get props => [scores];
}

class AssessmentsError extends AssessmentsState {
  final String message;

  const AssessmentsError(this.message);

  @override
  List<Object?> get props => [message];
}
