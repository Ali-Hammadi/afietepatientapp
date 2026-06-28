// feature/settings/presentation/models/share_doctor_option.dart
import 'package:equatable/equatable.dart';

class ShareDoctorOption extends Equatable {
  final String id;
  final String name;
  final String specialization;

  const ShareDoctorOption({
    required this.id,
    required this.name,
    required this.specialization,
  });

  @override
  List<Object?> get props => [id, name, specialization];
}
