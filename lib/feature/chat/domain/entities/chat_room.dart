// lib/features/chat/domain/entities/chat_room.dart
class ChatRoom {
  final String chatId;
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String doctorUsername;
  final String patientUsername;
  final bool canJoin;

  const ChatRoom({
    required this.chatId,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.doctorUsername,
    required this.patientUsername,
    required this.canJoin,
  });
}
