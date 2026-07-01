import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  const ChatRoomModel({
    required this.chatId,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.doctorUsername,
    required this.patientUsername,
    required this.canJoin,
  });

  final String chatId;
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String doctorUsername;
  final String patientUsername;
  final bool canJoin;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      chatId: _readString(json, const ['chat_id', 'chatId']) ?? '',
      appointmentId:
          _readString(json, const ['appointment_id', 'appointmentId']) ?? '',
      doctorId: _readString(json, const ['doctor_id', 'doctorId']) ?? '',
      patientId: _readString(json, const ['patient_id', 'patientId']) ?? '',
      doctorUsername:
          _readString(json, const ['doctor_username', 'doctorUsername']) ?? '',
      patientUsername:
          _readString(json, const ['patient_username', 'patientUsername']) ??
          '',
      canJoin: _readBool(json, const ['can_join', 'canJoin']),
    );
  }

  static String? _readString(Map source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return null;
  }

  static bool _readBool(Map source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final text = value.trim().toLowerCase();
        return text == 'true' || text == '1' || text == 'yes';
      }
    }
    return false;
  }
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderRole;
  final String text;
  final DateTime? createdAt;

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
