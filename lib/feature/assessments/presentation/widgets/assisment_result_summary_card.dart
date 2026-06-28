import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/feature/assessments/domain/entity/assisments_entity.dart';
import 'package:flutter/material.dart';

class CustomAssessmentsResultSummaryCard extends StatelessWidget {
  final AssessmentsEntity result;

  const CustomAssessmentsResultSummaryCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: (result.score / 100).clamp(0.0, 1.0),
                  strokeWidth: 8,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.primaryContainer,
                ),
                Center(
                  child: Text(
                    '${result.score}',
                    style: AppStyles.headingMedium.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            SettingsStrings.assessmentseverityLabel(result.severity),
            style: AppStyles.headingMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            SettingsStrings.assessmentsummaryLabel(
              result.severity,
              result.summary,
            ),
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
