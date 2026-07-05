// lib/feature/music_and_breathing/presentation/widgets/breathing_exercise_card.dart
import 'dart:core';

import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/feature/music_and_breathing/domain/entities/breathing_exercise_entity.dart';
import 'package:flutter/material.dart';

class BreathingExerciseCard extends StatelessWidget {
  final BreathingExerciseEntity exercise;
  final VoidCallback onStart;

  const BreathingExerciseCard({
    super.key,
    required this.exercise,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isArabic = SettingsStrings.isArabic;

    // ✅ استخدام النصوص المترجمة
    final localizedTitle = SettingsStrings.breathingExerciseName(exercise.type);
    final localizedDescription =
        SettingsStrings.breathingExerciseDescription(exercise.type);

    // ✅ ترجمة الخطوات
    final localizedSteps =
        SettingsStrings.translateBreathingSteps(exercise.steps);

    // ✅ ترجمة "موصى به لـ"
    final localizedRecommendedFor = SettingsStrings.translateRecommendedFor(
      exercise.recommendedFor,
    );

    // ✅ المحاذاة الديناميكية حسب اللغة
    final buttonAlignment =
        isArabic ? Alignment.centerLeft : Alignment.centerRight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // ✅ Header - مع محاذاة صحيحة
            Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      colorScheme.secondary.withValues(alpha: 0.12),
                  child: Icon(Icons.air_rounded, color: colorScheme.secondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedTitle,
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localizedRecommendedFor,
                        style: AppStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✅ الوصف
            Text(
              localizedDescription,
              style: AppStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 10),

            // ✅ الخطوات المترجمة
            if (localizedSteps.isNotEmpty)
              Wrap(
                alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: localizedSteps
                    .map(
                      (step) => Chip(
                        label: Text(
                          step,
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 11,
                          ),
                        ),
                        backgroundColor: colorScheme.primaryContainer
                            .withValues(alpha: 0.38),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),

            // ✅ زر البدء - محاذاة ديناميكية
            Align(
              alignment: buttonAlignment,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: Icon(
                  Icons.play_arrow_rounded,
                  // ✅ عكس الأيقونة في RTL
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                ),
                label: Text(SettingsStrings.startExercise),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
