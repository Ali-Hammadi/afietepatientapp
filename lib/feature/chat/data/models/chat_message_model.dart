// lib/features/chat/data/models/chat_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.senderRole,
    required super.text,
    super.createdAt,
  });

  factory ChatMessageModel.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final timestamp = data['createdAt'];
    return ChatMessageModel(
      id: snapshot.id,
      senderId: data['senderId']?.toString() ?? '',
      senderRole: data['senderRole']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
