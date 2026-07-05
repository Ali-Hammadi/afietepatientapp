// lib/feature/music_and_breathing/presentation/screens/breathing_exercise_screen.dart
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
  late List<_PhaseStep> _steps;
  late int _currentStepIndex;
  late int _remainingSeconds;
  late int _elapsedSeconds;
  bool _isRunning = false;
  bool _isCompleted = false;
  late String _currentLanguage; // ✅ تتبع اللغة الحالية

  @override
  void initState() {
    super.initState();
    _currentLanguage = SettingsStrings.isArabic ? 'ar' : 'en';
    _rebuildSteps();
    _currentStepIndex = 0;
    _remainingSeconds = _steps.isNotEmpty ? _steps.first.durationSeconds : 0;
    _elapsedSeconds = 0;

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {}
    });
  }

  // ✅ إعادة بناء الخطوات عند تغيير اللغة
  void _rebuildSteps() {
    _steps = _buildSteps(widget.exercise);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ التحقق من تغيير اللغة
    final newLanguage = SettingsStrings.isArabic ? 'ar' : 'en';
    if (newLanguage != _currentLanguage) {
      _currentLanguage = newLanguage;
      setState(() {
        _rebuildSteps();
        // ✅ إعادة تعيين الخطوة الحالية مع النص المترجم
        if (_steps.isNotEmpty) {
          _remainingSeconds = _steps[_currentStepIndex].durationSeconds;
        }
      });
    }
  }

  // ✅ ربط الأطوار بالثواني الحقيقية مع Localization
  List<_PhaseStep> _buildSteps(BreathingExerciseEntity exercise) {
    switch (exercise.type) {
      case BreathingExerciseType.boxBreathing:
        return [
          _PhaseStep(
            _PhaseType.inhale,
            SettingsStrings.inhaleLabel,
            exercise.inhaleSeconds,
          ),
          _PhaseStep(
            _PhaseType.hold,
            SettingsStrings.holdLabel,
            exercise.holdSeconds,
          ),
          _PhaseStep(
            _PhaseType.exhale,
            SettingsStrings.exhaleLabel,
            exercise.exhaleSeconds,
          ),
          _PhaseStep(
            _PhaseType.rest,
            SettingsStrings.restLabel,
            exercise.restSeconds,
          ),
        ];
      case BreathingExerciseType.fourSevenEight:
        return [
          _PhaseStep(
            _PhaseType.inhale,
            SettingsStrings.inhaleLabel,
            exercise.inhaleSeconds,
          ),
          _PhaseStep(
            _PhaseType.hold,
            SettingsStrings.holdLabel,
            exercise.holdSeconds,
          ),
          _PhaseStep(
            _PhaseType.exhale,
            SettingsStrings.exhaleLabel,
            exercise.exhaleSeconds,
          ),
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
          _PhaseStep(
            _PhaseType.inhale,
            SettingsStrings.inhaleLabel,
            exercise.inhaleSeconds,
          ),
          _PhaseStep(
            _PhaseType.exhale,
            SettingsStrings.exhaleLabel,
            exercise.exhaleSeconds,
          ),
        ];
    }
  }

  void _toggleRunning() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isCompleted && _isRunning) {
        _currentStepIndex = 0;
        _remainingSeconds =
            _steps.isNotEmpty ? _steps.first.durationSeconds : 0;
        _elapsedSeconds = 0;
        _isCompleted = false;
      }
    });
    if (_isRunning) {
      _tick();
    }
  }

  Future<void> _tick() async {
    while (mounted && _isRunning && !_isCompleted) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || !_isRunning || _isCompleted) break;

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

  Color _phaseColor(_PhaseType phaseType, ColorScheme colorScheme) {
    switch (phaseType) {
      case _PhaseType.inhale:
        return colorScheme.primary;
      case _PhaseType.hold:
        return colorScheme.tertiary;
      case _PhaseType.exhale:
        return colorScheme.secondary;
      case _PhaseType.rest:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentStep = _steps[_currentStepIndex];
    final totalSeconds = widget.exercise.durationMinutes * 60;
    final progress = totalSeconds == 0 ? 0.0 : _elapsedSeconds / totalSeconds;

    // ✅ استخدام النصوص المترجمة
    final exerciseTitle =
        SettingsStrings.breathingExerciseName(widget.exercise.type);
    final exerciseDescription =
        SettingsStrings.breathingExerciseDescription(widget.exercise.type);

    // ✅ ترجمة الخطوات
    final translatedSteps =
        SettingsStrings.translateBreathingSteps(widget.exercise.steps);

    final phaseColor = _phaseColor(currentStep.type, colorScheme);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(exerciseTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // ✅ استخدام SingleChildScrollView لمنع الـ overflow
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Badge نوع التمرين
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.air_rounded, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    exerciseTitle,
                    style: AppStyles.bodySmall.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ✅ الوصف
            Text(
              exerciseDescription,
              textAlign: TextAlign.center,
              style: AppStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // ✅ الدائرة الرئيسية
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: phaseColor.withValues(alpha: 0.15),
                border: Border.all(color: phaseColor, width: 6),
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
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentStep.label,
                        style: AppStyles.headingMedium.copyWith(
                          color: phaseColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _remainingSeconds.toString().padLeft(2, '0'),
                        style: AppStyles.headingLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ إحصائيات سريعة - محسّنة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatChip(
                  context,
                  icon: Icons.timer_outlined,
                  label: SettingsStrings.durationLabel,
                  value: SettingsStrings.minutesLabel(
                      widget.exercise.durationMinutes),
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  context,
                  icon: Icons.air_rounded,
                  label: SettingsStrings.totalBreaths,
                  value: _calculateTotalBreaths(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ الخطوات المترجمة
            if (translatedSteps.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_list_numbered_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          SettingsStrings.isArabic ? 'الخطوات' : 'Steps',
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...translatedSteps.map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $step',
                          style: AppStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // ✅ رسالة الحالة
            if (_isCompleted)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      SettingsStrings.exerciseComplete,
                      style: AppStyles.bodyMedium.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            // ✅ أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _toggleRunning,
                    icon: Icon(
                      _isCompleted
                          ? Icons.refresh_rounded
                          : _isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      _isCompleted
                          ? SettingsStrings.restartExercise
                          : _isRunning
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
                  tooltip: SettingsStrings.restartExercise,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ حساب إجمالي الأنفاس بشكل آمن
  String _calculateTotalBreaths() {
    final cycleDuration =
        widget.exercise.inhaleSeconds + widget.exercise.exhaleSeconds;
    if (cycleDuration == 0) return '0';

    final totalBreaths =
        (widget.exercise.durationMinutes * 60 / cycleDuration).round();
    return totalBreaths.toString();
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: AppStyles.bodySmall.copyWith(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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
