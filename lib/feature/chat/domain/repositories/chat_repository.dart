import 'package:afiete/feature/chat/domain/entities/chat_message.dart';
import 'package:afiete/feature/chat/domain/entities/chat_room.dart';

abstract class ChatRepository {
  Future<ChatRoom> getRoomForAppointment(String appointmentId);
  Stream<List<ChatMessage>> getMessagesStream(String chatId);

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  });
}
