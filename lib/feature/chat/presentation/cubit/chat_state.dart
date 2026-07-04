part of 'chat_cubit.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  const ChatLoaded({
    required this.room,
    required this.messages,
    required this.currentUserId,
  });

  final ChatRoomModel room;
  final List<ChatMessageModel> messages;
  final String currentUserId;
}

class ChatError extends ChatState {
  const ChatError(this.message);
  final String message;
}
