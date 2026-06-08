import '../../domain/entities/music_entity.dart';

class MusicModel extends MusicEntity {
  const MusicModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.audioUrl,
    required super.sourceName,
    required super.sourceUrl,
    required super.sourceType,
    required super.supportedFeelings,
    required super.therapeuticGoals,
    required super.isInstrumental,
    required super.durationSeconds,
    required super.tempoBpm,
    required super.noveltyScore,
    required super.licenseText,
    super.description,
    super.previewUrl,
    super.coverUrl,
    super.attributionText,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) {
    return MusicModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      description: json['description'] as String?,
      audioUrl: json['audio_url'] as String,
      previewUrl: json['preview_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      sourceName: json['source_name'] as String,
      sourceUrl: json['source_url'] as String,
      sourceType: MusicSourceType.values.byName(json['source_type'] as String),
      supportedFeelings: (json['supported_feelings'] as List)
          .map((e) => FeelingType.values.byName(e as String))
          .toList(),
      therapeuticGoals: (json['therapeutic_goals'] as List)
          .map((e) => MusicTherapeuticGoal.values.byName(e as String))
          .toList(),
      isInstrumental: json['is_instrumental'] as bool,
      durationSeconds: json['duration_seconds'] as int,
      tempoBpm: json['tempo_bpm'] as int,
      noveltyScore: json['novelty_score'] as int,
      licenseText: json['license_text'] as String,
      attributionText: json['attribution_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'description': description,
      'audio_url': audioUrl,
      'preview_url': previewUrl,
      'cover_url': coverUrl,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'source_type': sourceType.name,
      'supported_feelings': supportedFeelings.map((e) => e.name).toList(),
      'therapeutic_goals': therapeuticGoals.map((e) => e.name).toList(),
      'is_instrumental': isInstrumental,
      'duration_seconds': durationSeconds,
      'tempo_bpm': tempoBpm,
      'novelty_score': noveltyScore,
      'license_text': licenseText,
      'attribution_text': attributionText,
    };
  }
}
