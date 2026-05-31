import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/settings/domin/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class ShareMedicalNoteWithDoctorParams {
  final String userId;
  final String noteTitle;
  final String noteContent;
  final String doctorId;

  const ShareMedicalNoteWithDoctorParams({
    required this.userId,
    required this.noteTitle,
    required this.noteContent,
    required this.doctorId,
  });
}

class ShareMedicalNoteWithDoctorUseCase
    implements UseCase<String, ShareMedicalNoteWithDoctorParams> {
  final SettingsRepository repository;

  const ShareMedicalNoteWithDoctorUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(
    ShareMedicalNoteWithDoctorParams params,
  ) {
    return repository.shareMedicalNoteWithDoctor(
      userId: params.userId,
      noteTitle: params.noteTitle,
      noteContent: params.noteContent,
      doctorId: params.doctorId,
    );
  }
}
