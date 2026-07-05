// lib/feature/home/presentation/widgets/emotions_widget.dart
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/feature/feeling/presentation/cubit/feeling_cubit.dart';
import 'package:afiete/feature/music_and_breathing/domain/entities/music_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomEmotionsWidget extends StatelessWidget {
  const CustomEmotionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppStyles.padding),
      child: BlocBuilder<FeelingCubit, FeelingState>(
        builder: (context, state) {
          // ✅ استخراج الشعور المختار وحالة القفل
          final FeelingType? selectedFeeling;
          final bool isLocked;

          switch (state) {
            case FeelingLoaded():
              selectedFeeling = state.selectedFeeling;
              isLocked = state.hasLockedFeeling;
              break;
            case FeelingError():
              selectedFeeling = state.selectedFeeling;
              isLocked = state.hasLockedFeeling;
              break;
            default:
              selectedFeeling = null;
              isLocked = false;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ رسالة القفل إذا كان مقفل
              if (isLocked)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          SettingsStrings.feelingAlreadySelected,
                          style: AppStyles.bodySmall.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _items.map((item) {
                  final isSelected = selectedFeeling == item.feeling;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(AppStyles.borderRadius),
                        onTap: isLocked
                            ? null // ✅ تعطيل النقر إذا مقفل
                            : () {
                                context
                                    .read<FeelingCubit>()
                                    .selectFeeling(item.feeling);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.primaryContainer
                                    .withValues(alpha: isLocked ? 0.25 : 0.45),
                            borderRadius: BorderRadius.circular(
                              AppStyles.borderRadius,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.primary.withValues(
                                      alpha: isLocked ? 0.15 : 0.2,
                                    ),
                              width: isSelected ? 2 : 1,
                            ),
                            // ✅ تأثير shadow عند الاختيار
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: 26,
                                color: isSelected
                                    ? colorScheme.primary
                                    : isLocked
                                        ? colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.5)
                                        : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                style: AppStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : isLocked
                                          ? colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5)
                                          : colorScheme.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ],
          );
        },
      ),
    );
  }

  static List<_FeelingItem> get _items => [
        _FeelingItem(
          feeling: FeelingType.happy,
          icon: Icons.sentiment_very_satisfied_rounded,
          label: SettingsStrings.feelingHappyLabel,
        ),
        _FeelingItem(
          feeling: FeelingType.sad,
          icon: Icons.sentiment_very_dissatisfied_rounded,
          label: SettingsStrings.feelingSadLabel,
        ),
        _FeelingItem(
          feeling: FeelingType.angry,
          icon: Icons.mood_bad_rounded,
          label: SettingsStrings.feelingAngryLabel,
        ),
        _FeelingItem(
          feeling: FeelingType.neutral,
          icon: Icons.sentiment_neutral_rounded,
          label: SettingsStrings.feelingNeutralLabel,
        ),
        _FeelingItem(
          feeling: FeelingType.anxious,
          icon: Icons.psychology_alt_rounded,
          label: SettingsStrings.feelingAnxiousLabel,
        ),
      ];
}

class _FeelingItem {
  final FeelingType feeling;
  final IconData icon;
  final String label;

  const _FeelingItem({
    required this.feeling,
    required this.icon,
    required this.label,
  });
}
