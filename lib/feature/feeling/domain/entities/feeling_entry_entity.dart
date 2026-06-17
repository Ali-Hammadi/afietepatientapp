import 'package:afiete/feature/music_and_breathing/domain/entities/music_entity.dart';
import 'package:equatable/equatable.dart';

class FeelingEntryEntity extends Equatable {
  final String id;
  final FeelingType feeling;
  final int intensity;
  final DateTime createdAt;

  const FeelingEntryEntity({
    required this.id,
    required this.feeling,
    required this.intensity,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, feeling, intensity, createdAt];
}
