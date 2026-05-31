import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/video/domain/entities/video_call_entity.dart';
import 'package:afietepatientapp/feature/video/domain/repositories/video_repository.dart';
import 'package:dartz/dartz.dart';

class EndVideoCallUseCase
    implements UseCase<VideoCallEntity, EndVideoCallParams> {
  final VideoRepository repository;

  const EndVideoCallUseCase(this.repository);

  @override
  Future<Either<Failure, VideoCallEntity>> call(EndVideoCallParams params) {
    return repository.endCall(params.callId);
  }
}

class EndVideoCallParams {
  final String callId;

  const EndVideoCallParams({required this.callId});
}
