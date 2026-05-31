import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/voice/domain/entities/voice_call_entity.dart';
import 'package:afietepatientapp/feature/voice/domain/repositories/voice_repository.dart';
import 'package:dartz/dartz.dart';

class EndVoiceCallUseCase
    implements UseCase<VoiceCallEntity, EndVoiceCallParams> {
  final VoiceRepository repository;

  const EndVoiceCallUseCase(this.repository);

  @override
  Future<Either<Failure, VoiceCallEntity>> call(EndVoiceCallParams params) {
    return repository.endCall(params.callId);
  }
}

class EndVoiceCallParams {
  final String callId;

  const EndVoiceCallParams({required this.callId});
}
