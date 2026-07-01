import 'package:afiete/feature/chat/chat/data/model/chat_model.dart';
import 'package:afiete/feature/chat/chat/data/services/chat_services.dart';

class ChatRepository {
  ChatRepository(this._service);

  final ChatService _service;

  Future<ChatRoomModel> roomForAppointment(String appointmentId) {
    return _service.roomForAppointment(appointmentId);
  }

  Stream<List<ChatMessageModel>> messages(String chatId) {
    return _service.messages(chatId);
  }

  Future<void> sendMessage({required String chatId, required String text}) {
    return _service.sendMessage(chatId: chatId, text: text);
  }

  String? get currentFirebaseUid => _service.currentFirebaseUid;
}
