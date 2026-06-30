// lib/features/chat/domain/entities/chat_message.dart
class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole;
  final String text;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    this.createdAt,
  });
}
