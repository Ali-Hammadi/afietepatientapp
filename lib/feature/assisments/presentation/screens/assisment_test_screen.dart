import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/feature/assisments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assisments/presentation/cubits/assisments_cubit.dart';
import 'package:afiete/feature/assisments/presentation/screens/assisment_last_scores_screen.dart';
import 'package:afiete/feature/assisments/presentation/screens/assisment_result_screen.dart';
import 'package:afiete/feature/assisments/presentation/widgets/assisment_bottom_actions.dart';
import 'package:afiete/feature/assisments/presentation/widgets/assisment_error_view.dart';
import 'package:afiete/feature/assisments/presentation/widgets/assisment_option_tile.dart';
import 'package:afiete/feature/assisments/presentation/widgets/assisment_progress_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssismentTestScreen extends StatelessWidget {
  const AssismentTestScreen({super.key});

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
      body: BlocBuilder<AssismentsCubit, AssismentsState>(
        builder: (context, state) {
          if (state is AssismentsLoading || state is AssismentsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AssismentsSubmitting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AssismentsError) {
            return CustomAssismentErrorView(
              message: state.message,
              onRetry: () => context.read<AssismentsCubit>().loadQuestions(),
            );
          }

          if (state is AssismentsResultLoaded) {
            return AssismentResultScreen(state: state);
          }

          if (state is AssismentsLastScoresLoaded) {
            return AssismentLastScoresScreen(scores: state.scores);
          }

          if (state is! AssismentsLoaded) {
            return const SizedBox.shrink();
          }

          if (!state.hasQuestions) {
            return CustomAssismentErrorView(
              message: SettingsStrings.assessmentNoQuestionsAvailable,
              onRetry: () => context.read<AssismentsCubit>().loadQuestions(),
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
                      CustomAssismentProgressHeader(
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
                          color:
                              (theme.textTheme.bodyMedium?.color ??
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
              CustomAssismentBottomActions(
                showBack: state.currentQuestionIndex > 0,
                isLastQuestion: isLastQuestion,
                onBack: () =>
                    context.read<AssismentsCubit>().goToPreviousQuestion(),
                onContinueOrSubmit: () {
                  if (isLastQuestion) {
                    context.read<AssismentsCubit>().submitCurrentAssisment();
                    return;
                  }
                  context.read<AssismentsCubit>().goToNextQuestion();
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
    required List<AssismentOptionEntity> options,
  }) {
    return options
        .map(
          (option) => CustomAssismentOptionTile(
            option: option.text,
            isSelected: selectedAnswerId == option.id,
            onTap: () => context.read<AssismentsCubit>().selectAnswer(
              questionId: questionId,
              answerId: option.id,
            ),
          ),
        )
        .toList();
  }
}
