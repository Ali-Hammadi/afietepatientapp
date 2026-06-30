// lib/features/chat/presentation/cubit/chat_state.dart
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/chat_message.dart';

sealed class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  const ChatLoaded(
      {required this.room,
      required this.messages,
      required this.currentUserId});
  final ChatRoom room;
  final List<ChatMessage> messages;
  final String currentUserId;
}

class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;
}
