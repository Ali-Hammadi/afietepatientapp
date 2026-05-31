import 'package:afietepatientapp/core/error/failure.dart';
import 'package:afietepatientapp/core/usecases/usecase.dart';
import 'package:afietepatientapp/feature/chat/domain/entities/chat_entity.dart';
import 'package:afietepatientapp/feature/chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class SendChatMessageUseCase
    implements UseCase<ChatMessageEntity, SendChatMessageParams> {
  final ChatRepository repository;

  const SendChatMessageUseCase(this.repository);

  @override
  Future<Either<Failure, ChatMessageEntity>> call(
    SendChatMessageParams params,
  ) {
    return repository.sendMessage(
      conversationId: params.conversationId,
      senderId: params.senderId,
      receiverId: params.receiverId,
      message: params.message,
    );
  }
}

class SendChatMessageParams {
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String message;

  const SendChatMessageParams({
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.message,
  });
}
