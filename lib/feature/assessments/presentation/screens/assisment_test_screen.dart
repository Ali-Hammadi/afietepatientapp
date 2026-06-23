import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_cubit.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_state.dart';
import 'package:afiete/feature/assessments/presentation/screens/assisment_last_scores_screen.dart';
import 'package:afiete/feature/assessments/presentation/screens/assisment_result_screen.dart';
import 'package:afiete/feature/assessments/presentation/widgets/assisment_bottom_actions.dart';
import 'package:afiete/feature/assessments/presentation/widgets/assisment_error_view.dart';
import 'package:afiete/feature/assessments/presentation/widgets/assisment_option_tile.dart';
import 'package:afiete/feature/assessments/presentation/widgets/assisment_progress_header.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssessmentsTestScreen extends StatelessWidget {
  const AssessmentsTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          SettingsStrings.assessmentTitle,
          style: AppStyles.headingMedium,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AssessmentsCubit, AssessmentsState>(
        builder: (context, state) {
          if (state is AssessmentsLoading || state is AssessmentsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AssessmentsSubmitting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AssessmentsError) {
            return CustomAssessmentsErrorView(
              message: state.message,
              onRetry: () => context.read<AssessmentsCubit>().loadQuestions(),
            );
          }

          if (state is AssessmentsResultLoaded) {
            return AssessmentsResultScreen(state: state);
          }

          if (state is AssessmentsLastScoresLoaded) {
            return AssessmentsLastScoresScreen(scores: state.scores);
          }

          if (state is! AssessmentsLoaded) {
            return const SizedBox.shrink();
          }

          if (!state.hasQuestions) {
            return CustomAssessmentsErrorView(
              message: SettingsStrings.assessmentNoQuestionsAvailable,
              onRetry: () => context.read<AssessmentsCubit>().loadQuestions(),
            );
          }

          final question = state.currentQuestion!;
          final selectedAnswerId = state.selectedAnswers[question.id];
          final isLastQuestion =
              state.currentQuestionIndex == state.questions.length - 1;
          final progress =
              (state.currentQuestionIndex + 1) / state.questions.length;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppStyles.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAssessmentsProgressHeader(
                        progress: progress,
                        questionIndex: state.currentQuestionIndex + 1,
                        totalQuestions: state.questions.length,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        question.questionText,
                        style: AppStyles.headingMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        SettingsStrings.assessmentPrompt,
                        style: AppStyles.bodyMedium.copyWith(
                          color: (theme.textTheme.bodyMedium?.color ??
                                  colorScheme.onSurface)
                              .withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._buildOptions(
                        context: context,
                        questionId: question.id,
                        selectedAnswerId: selectedAnswerId,
                        options: question.options,
                      ),
                      if (state.validationError != null &&
                          state.validationError!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          state.validationError!,
                          style: AppStyles.bodySmall.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              CustomAssessmentsBottomActions(
                showBack: state.currentQuestionIndex > 0,
                isLastQuestion: isLastQuestion,
                onBack: () =>
                    context.read<AssessmentsCubit>().goToPreviousQuestion(),
                onContinueOrSubmit: () {
                  if (isLastQuestion) {
                    context.read<AssessmentsCubit>().submitCurrentAssessments();
                    return;
                  }
                  context.read<AssessmentsCubit>().goToNextQuestion();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildOptions({
    required BuildContext context,
    required int questionId,
    required int? selectedAnswerId,
    required List<AssessmentsOptionEntity> options,
  }) {
    return options
        .map(
          (option) => CustomAssessmentsOptionTile(
            option: option.text,
            isSelected: selectedAnswerId == option.id,
            onTap: () => context.read<AssessmentsCubit>().selectAnswer(
                  questionId: questionId,
                  answerId: option.id,
                ),
          ),
        )
        .toList();
  }
}
