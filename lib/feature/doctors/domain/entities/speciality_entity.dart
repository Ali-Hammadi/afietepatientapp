import 'package:equatable/equatable.dart';

class SpecialtyEntity extends Equatable {
  final int id;
  final String name;

  const SpecialtyEntity({required this.id, required this.name});

  factory SpecialtyEntity.fromJson(Map<String, dynamic> json) {
    return SpecialtyEntity(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
