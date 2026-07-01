// lib/features/chat/presentation/cubit/chat_cubit.dart
import 'package:afiete/feature/chat/domain/entities/chat_room.dart';
import 'package:afiete/feature/chat/domain/usecases/chat_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.getChatRoom,
    required this.getMessagesStream,
    required this.sendMessage,
  }) : super(const ChatInitial());

  final GetChatRoom getChatRoom;
  final GetMessagesStream getMessagesStream;
  final SendMessage sendMessage;

  StreamSubscription? _subscription;
  ChatRoom? _room;
  String? _currentUserId; // 💡 متغير لحفظ الآيدي الفعلي للمستخدم

  Future<void> openAppointmentChat(
    String appointmentId, {
    String? currentUserId,
  }) async {
    emit(const ChatLoading());
    try {
      final room = await getChatRoom(appointmentId);
      _room = room;
      await _subscription?.cancel();

      // 💡 نحتفظ بالآيدي الممرر من الشاشة أو القادم من الغرفة
      _currentUserId = currentUserId ?? room.patientId;

      _subscription = getMessagesStream(room.chatId).listen(
        (messages) => emit(ChatLoaded(
          room: room,
          messages: messages,
          currentUserId: _currentUserId!, // ✅ نمرر الآيدي الفعلي المستقر
        )),
        onError: (error) => emit(ChatError(error.toString())),
      );
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  Future<void> send(String text) async {
    final room = _room;
    // 💡 نتحقق من وجود الغرفة ومن وجود آيدي صالح للمستخدم
    if (room == null || _currentUserId == null || _currentUserId!.isEmpty)
      return;
    try {
      await sendMessage(
        chatId: room.chatId,
        senderId:
            _currentUserId!, // ✅ نرسل الآيدي الحقيقي للمستخدم وليس النص الفارغ
        text: text,
      );
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
