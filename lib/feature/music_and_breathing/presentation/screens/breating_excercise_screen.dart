import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/feature/music_and_breathing/domain/entities/breathing_exercise_entity.dart';
import 'package:afiete/feature/music_and_breathing/domain/entities/music_entity.dart';
import 'package:flutter/material.dart';

class BreathingExerciseScreen extends StatefulWidget {
  final BreathingExerciseEntity exercise;

  const BreathingExerciseScreen({super.key, required this.exercise});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  late final List<_PhaseStep> _steps;
  late int _currentStepIndex;
  late int _remainingSeconds;
  late int _elapsedSeconds;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _steps = _buildSteps(widget.exercise);
    _currentStepIndex = 0;
    _remainingSeconds = _steps.isNotEmpty ? _steps.first.durationSeconds : 0;
    _elapsedSeconds = 0;
  }

  // ربط الأطوار بالثواني الحقيقية القادمة ديناميكياً من الـ Entity والسيرفر
  List<_PhaseStep> _buildSteps(BreathingExerciseEntity exercise) {
    switch (exercise.type) {
      case BreathingExerciseType.boxBreathing:
        return [
          _PhaseStep(_PhaseType.inhale, SettingsStrings.inhaleLabel,
              exercise.inhaleSeconds),
          _PhaseStep(
              _PhaseType.hold, SettingsStrings.holdLabel, exercise.holdSeconds),
          _PhaseStep(_PhaseType.exhale, SettingsStrings.exhaleLabel,
              exercise.exhaleSeconds),
          _PhaseStep(
              _PhaseType.rest, SettingsStrings.holdLabel, exercise.restSeconds),
        ];
      case BreathingExerciseType.fourSevenEight:
        return [
          _PhaseStep(_PhaseType.inhale, SettingsStrings.inhaleLabel,
              exercise.inhaleSeconds),
          _PhaseStep(
              _PhaseType.hold, SettingsStrings.holdLabel, exercise.holdSeconds),
          _PhaseStep(_PhaseType.exhale, SettingsStrings.exhaleLabel,
              exercise.exhaleSeconds),
        ];
      case BreathingExerciseType.diaphragmatic:
        return [
          _PhaseStep(
            _PhaseType.inhale,
            '${SettingsStrings.inhaleLabel} (${SettingsStrings.bellyLabel})',
            exercise.inhaleSeconds,
          ),
          _PhaseStep(
            _PhaseType.exhale,
            '${SettingsStrings.slowLabel} ${SettingsStrings.exhaleLabel}',
            exercise.exhaleSeconds,
          ),
        ];
      case BreathingExerciseType.pacedBreathing:
      case BreathingExerciseType.resonance:
        return [
          _PhaseStep(_PhaseType.inhale, SettingsStrings.inhaleLabel,
              exercise.inhaleSeconds),
          _PhaseStep(_PhaseType.exhale, SettingsStrings.exhaleLabel,
              exercise.exhaleSeconds),
        ];
    }
  }

  void _toggleRunning() {
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _tick();
    }
  }

  Future<void> _tick() async {
    while (mounted && _isRunning && !_isCompleted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || !_isRunning || _isCompleted) {
        break;
      }

      setState(() {
        _elapsedSeconds += 1;
        _remainingSeconds -= 1;
        if (_remainingSeconds <= 0) {
          _currentStepIndex = (_currentStepIndex + 1) % _steps.length;
          _remainingSeconds = _steps[_currentStepIndex].durationSeconds;
        }
        if (_elapsedSeconds >= widget.exercise.durationMinutes * 60) {
          _isRunning = false;
          _isCompleted = true;
        }
      });
    }
  }

  String _phaseLabel(_PhaseType phaseType) {
    switch (phaseType) {
      case _PhaseType.inhale:
        return SettingsStrings.inhaleLabel;
      case _PhaseType.hold:
        return SettingsStrings.holdLabel;
      case _PhaseType.exhale:
        return SettingsStrings.exhaleLabel;
      case _PhaseType.rest:
        return SettingsStrings.restLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentStep = _steps[_currentStepIndex];
    final totalSeconds = widget.exercise.durationMinutes * 60;
    final progress = totalSeconds == 0 ? 0.0 : _elapsedSeconds / totalSeconds;

    final localizedTitle = widget.exercise.type;
    final localizedDescription = widget.exercise.type;

    // تم استخدام مصفوفة الـ steps الممررة ديناميكياً داخل الكائن نفسه
    final currentExerciseSteps = widget.exercise.steps;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(localizedTitle as String), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              localizedDescription as String,
              textAlign: TextAlign.center,
              style: AppStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer.withAlpha(140),
                border: Border.all(color: colorScheme.primary, width: 6),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: colorScheme.primary.withAlpha(30),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentStep.label,
                        style: AppStyles.headingMedium.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _remainingSeconds.toString().padLeft(2, '0'),
                        style: AppStyles.headingLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _phaseLabel(currentStep.type),
                        style: AppStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              currentExerciseSteps.join('\n'),
              textAlign: TextAlign.center,
              style: AppStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _toggleRunning,
                    child: Text(
                      _isRunning
                          ? SettingsStrings.pauseExercise
                          : SettingsStrings.startExercise,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      _isRunning = false;
                      _isCompleted = false;
                      _currentStepIndex = 0;
                      _remainingSeconds =
                          _steps.isNotEmpty ? _steps.first.durationSeconds : 0;
                      _elapsedSeconds = 0;
                    });
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _PhaseType { inhale, hold, exhale, rest }

class _PhaseStep {
  final _PhaseType type;
  final String label;
  final int durationSeconds;

  const _PhaseStep(this.type, this.label, this.durationSeconds);
}
