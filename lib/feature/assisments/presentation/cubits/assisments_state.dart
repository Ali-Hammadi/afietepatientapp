part of 'assisments_cubit.dart';

abstract class AssismentsState extends Equatable {
  const AssismentsState();

  @override
  List<Object?> get props => [];
}

class AssismentsInitial extends AssismentsState {
  const AssismentsInitial();
}

class AssismentsLoading extends AssismentsState {
  const AssismentsLoading();
}

class AssismentsLoaded extends AssismentsState {
  final List<AssismentEntity> questions;
  final Map<int, int> selectedAnswers;
  final int currentQuestionIndex;
  final String? validationError;

  const AssismentsLoaded({
    required this.questions,
    required this.selectedAnswers,
    required this.currentQuestionIndex,
    this.validationError,
  });

  bool get hasQuestions => questions.isNotEmpty;

  AssismentEntity? get currentQuestion =>
      hasQuestions ? questions[currentQuestionIndex] : null;

  AssismentsLoaded copyWith({
    List<AssismentEntity>? questions,
    Map<int, int>? selectedAnswers,
    int? currentQuestionIndex,
    String? validationError,
  }) {
    return AssismentsLoaded(
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

class AssismentsSubmitting extends AssismentsState {
  const AssismentsSubmitting();
}

class AssismentsResultLoaded extends AssismentsState {
  final AssismentEntity result;
  final List<DoctorEntity> doctors;

  const AssismentsResultLoaded({required this.result, required this.doctors});

  @override
  List<Object?> get props => [result, doctors];
}

class AssismentsLastScoresLoaded extends AssismentsState {
  final List<AssessmentScoreEntry> scores;

  const AssismentsLastScoresLoaded({required this.scores});

  @override
  List<Object?> get props => [scores];
}

class AssismentsError extends AssismentsState {
  final String message;

  const AssismentsError(this.message);

  @override
  List<Object?> get props => [message];
}
