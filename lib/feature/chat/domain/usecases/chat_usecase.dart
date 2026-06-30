// lib/features/chat/domain/usecases/chat_usecases.dart
import '../entities/chat_room.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetChatRoom {
  final ChatRepository _repository;
  GetChatRoom(this._repository);
  Future<ChatRoom> call(String appointmentId) =>
      _repository.getRoomForAppointment(appointmentId);
}

class GetMessagesStream {
  final ChatRepository _repository;
  GetMessagesStream(this._repository);
  Stream<List<ChatMessage>> call(String chatId) =>
      _repository.getMessagesStream(chatId);
}

class SendMessage {
  final ChatRepository _repository;
  SendMessage(this._repository);
  Future<void> call(
          {required String chatId,
          required String senderId,
          required String text}) =>
      _repository.sendMessage(chatId: chatId, senderId: senderId, text: text);
}
