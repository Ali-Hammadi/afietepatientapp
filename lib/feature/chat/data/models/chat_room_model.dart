// lib/features/chat/data/models/chat_room_model.dart
import '../../domain/entities/chat_room.dart';

class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.chatId,
    required super.appointmentId,
    required super.doctorId,
    required super.patientId,
    required super.doctorUsername,
    required super.patientUsername,
    required super.canJoin,
  });

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
