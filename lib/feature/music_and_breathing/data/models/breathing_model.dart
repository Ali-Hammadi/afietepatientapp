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
    return BreathingExerciseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: BreathingExerciseType.values.byName(json['type'] as String),
      durationMinutes: json['duration_minutes'] as int,
      inhaleSeconds: json['inhale_seconds'] as int,
      holdSeconds: json['hold_seconds'] as int,
      exhaleSeconds: json['exhale_seconds'] as int,
      restSeconds: json['rest_seconds'] as int,
      steps: List<String>.from(json['steps'] as List),
      recommendedFor: json['recommended_for'] as String,
    );
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
