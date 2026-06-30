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

  Future<void> openAppointmentChat(String appointmentId) async {
    emit(const ChatLoading());
    try {
      final room = await getChatRoom(appointmentId);
      _room = room;
      await _subscription?.cancel();

      _subscription = getMessagesStream(room.chatId).listen(
        (messages) => emit(ChatLoaded(
          room: room,
          messages: messages,
          currentUserId: room.patientId, // 🔴 نستخدم patientId من الـ Room
        )),
        onError: (error) => emit(ChatError(error.toString())),
      );
    } catch (error) {
      emit(ChatError(error.toString()));
    }
  }

  Future<void> send(String text) async {
    final room = _room;
    if (room == null) return;
    try {
      await sendMessage(
        chatId: room.chatId,
        senderId: room.patientId,
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
