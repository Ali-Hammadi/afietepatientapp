// lib/features/chat/data/repositories/chat_repository_impl.dart
import 'package:afiete/feature/chat/data/datasources/chat_remote_datasource.dart';

import '../../domain/entities/chat_room.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remoteDataSource);
  final ChatRemoteDataSource _remoteDataSource;

  @override
  Future<ChatRoom> getRoomForAppointment(String appointmentId) =>
      _remoteDataSource.getRoomForAppointment(appointmentId);

  @override
  Stream<List<ChatMessage>> getMessagesStream(String chatId) =>
      _remoteDataSource.getMessagesStream(chatId);

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) =>
      _remoteDataSource.sendMessage(
          chatId: chatId, senderId: senderId, text: text);
}
