// lib/feature/music_and_breathing/data/models/breathing_model.dart
import '../../domain/entities/breathing_exercise_entity.dart';
import '../../domain/entities/music_entity.dart';

class BreathingExerciseModel extends BreathingExerciseEntity {
  const BreathingExerciseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.durationMinutes,
    required super.inhaleSeconds,
    required super.holdSeconds,
    required super.exhaleSeconds,
    required super.restSeconds,
    required super.steps,
    required super.recommendedFor,
  });

  factory BreathingExerciseModel.fromJson(Map<String, dynamic> json) {
    // ✅ إصلاح مشكلة Closure - التأكد من إن steps هي List<String>
    final rawSteps = json['steps'];
    List<String> parsedSteps = [];

    if (rawSteps is List) {
      for (final item in rawSteps) {
        if (item is String) {
          parsedSteps.add(item);
        } else if (item != null) {
          parsedSteps.add(item.toString());
        }
      }
    }

    return BreathingExerciseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: _parseType(json['type']),
      durationMinutes: json['duration_minutes'] as int? ?? 5,
      inhaleSeconds: json['inhale_seconds'] as int? ?? 4,
      holdSeconds: json['hold_seconds'] as int? ?? 4,
      exhaleSeconds: json['exhale_seconds'] as int? ?? 4,
      restSeconds: json['rest_seconds'] as int? ?? 0,
      steps: parsedSteps, // ✅ List<String> مباشرة
      recommendedFor: json['recommended_for']?.toString() ?? '',
    );
  }

  static BreathingExerciseType _parseType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'boxbreathing':
        case 'box_breathing':
          return BreathingExerciseType.boxBreathing;
        case 'fourseveneight':
        case 'four_seven_eight':
        case '478':
          return BreathingExerciseType.fourSevenEight;
        case 'diaphragmatic':
          return BreathingExerciseType.diaphragmatic;
        case 'pacedbreathing':
        case 'paced_breathing':
          return BreathingExerciseType.pacedBreathing;
        case 'resonance':
          return BreathingExerciseType.resonance;
        default:
          return BreathingExerciseType.boxBreathing;
      }
    }
    return BreathingExerciseType.boxBreathing;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'duration_minutes': durationMinutes,
      'inhale_seconds': inhaleSeconds,
      'hold_seconds': holdSeconds,
      'exhale_seconds': exhaleSeconds,
      'rest_seconds': restSeconds,
      'steps': steps,
      'recommended_for': recommendedFor,
    };
  }
}
