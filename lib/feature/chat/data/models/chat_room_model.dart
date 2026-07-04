import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  const ChatRoomModel({
    required this.courseId,
    required this.doctorUsername,
    required this.patientUsername,
    required this.isArchived,
    required this.courseStatus,
    this.lastMessage,
    this.lastMessageAt,
    this.lastSenderUsername,
  });

  final String courseId;
  final String doctorUsername;
  final String patientUsername;
  final bool isArchived;
  final String courseStatus;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderUsername;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      courseId: json['course_id']?.toString() ?? json['id']?.toString() ?? '',
      doctorUsername: json['doctor_username']?.toString() ?? '',
      patientUsername: json['patient_username']?.toString() ?? '',
      isArchived: json['is_archived'] == true || json['is_archived'] == 'true',
      courseStatus: json['course_status']?.toString() ?? 'active',
      lastMessage: json['last_message']?.toString(),
      lastMessageAt: json['last_message_at'] is Timestamp
          ? (json['last_message_at'] as Timestamp).toDate()
          : null,
      lastSenderUsername: json['last_sender_username']?.toString(),
    );
  }
}
