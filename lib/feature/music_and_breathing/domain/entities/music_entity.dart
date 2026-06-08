import 'package:equatable/equatable.dart';

enum BreathingExerciseType {
  boxBreathing,
  fourSevenEight,
  diaphragmatic,
  pacedBreathing,
  resonance
}

enum MusicTherapeuticGoal { calmDown, uplift, stabilize, focus, sleep }

enum MusicSourceType {
  bensound,
  freemusicarchive,
  pixabay,
  incompetech,
  custom
}

enum FeelingType { happy, sad, angry, neutral, anxious }

class MusicEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? description;
  final String audioUrl;
  final String? previewUrl;
  final String? coverUrl;
  final String sourceName;
  final String sourceUrl;
  final MusicSourceType sourceType;
  final List<FeelingType> supportedFeelings;
  final List<MusicTherapeuticGoal> therapeuticGoals;
  final bool isInstrumental;
  final int durationSeconds;
  final int tempoBpm;
  final int noveltyScore;
  final String licenseText;
  final String? attributionText;

  const MusicEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.sourceName,
    required this.sourceUrl,
    required this.sourceType,
    required this.supportedFeelings,
    required this.therapeuticGoals,
    required this.isInstrumental,
    required this.durationSeconds,
    required this.tempoBpm,
    required this.noveltyScore,
    required this.licenseText,
    this.description,
    this.previewUrl,
    this.coverUrl,
    this.attributionText,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        description,
        audioUrl,
        previewUrl,
        coverUrl,
        sourceName,
        sourceUrl,
        sourceType,
        supportedFeelings,
        therapeuticGoals,
        isInstrumental,
        durationSeconds,
        tempoBpm,
        noveltyScore,
        licenseText,
        attributionText,
      ];
}
