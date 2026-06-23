import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';
import 'package:afiete/feature/assessments/presentation/cubits/assessments_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssessmentsLastScoresScreen extends StatelessWidget {
  final List<AssessmentScoreEntry> scores;

  const AssessmentsLastScoresScreen({super.key, required this.scores});

  Color _severityColor(BuildContext context, String severity) {
    final s = severity.toLowerCase();
    if (s.contains('severe') || s.contains('high')) {
      return Colors.red.shade600;
    }
    if (s.contains('moderate') || s.contains('medium')) {
      return Colors.orange.shade600;
    }
    if (s.contains('mild') || s.contains('low')) {
      return Colors.yellow.shade700;
    }
    return Colors.green.shade600;
  }

  String _severityLabel(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('severe')) return SettingsStrings.severitySevere;
    if (s.contains('moderate')) return SettingsStrings.severityModerate;
    if (s.contains('mild')) return SettingsStrings.severityMild;
    if (s.contains('minimal') || s.isEmpty)
      return SettingsStrings.severityMinimal;
    return severity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              SettingsStrings.lastAssessmentResultTitle,
              style: AppStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              SettingsStrings.lastAssessmentResultSubtitle,
              style: AppStyles.bodyMedium.copyWith(
                color:
                    (theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface)
                        .withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ...scores.map((entry) => _ScoreCard(
                entry: entry,
                severityColor: _severityColor(context, entry.severity),
                severityLabel: _severityLabel(entry.severity),
              )),
          const SizedBox(height: 24),
          CustomButton(
            widget: Text(
              SettingsStrings.retakeAssessment,
              style: AppStyles.bodyMedium.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
            onPressed: () => context.read<AssessmentsCubit>().loadQuestions(),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final AssessmentScoreEntry entry;
  final Color severityColor;
  final String severityLabel;

  const _ScoreCard({
    required this.entry,
    required this.severityColor,
    required this.severityLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (entry.score / 100).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  color: severityColor,
                  backgroundColor: severityColor.withValues(alpha: 0.15),
                ),
                Center(
                  child: Text(
                    '${entry.score}%',
                    style: AppStyles.bodySmall.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: AppStyles.headingSmall,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    severityLabel,
                    style: AppStyles.bodySmall.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.raw} / ${entry.max}',
                  style: AppStyles.bodySmall.copyWith(
                    color: (theme.textTheme.bodySmall?.color ??
                            colorScheme.onSurface)
                        .withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
