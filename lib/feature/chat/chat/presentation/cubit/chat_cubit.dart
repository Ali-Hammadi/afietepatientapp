import 'dart:async';

import 'package:afiete/feature/chat/chat/data/model/chat_model.dart';
import 'package:afiete/feature/chat/chat/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(const ChatInitial());

  final ChatRepository _repository;
  StreamSubscription<List<ChatMessageModel>>? _subscription;
  ChatRoomModel? _room;

  Future<void> openAppointmentChat(String appointmentId) async {
    emit(const ChatLoading());
    try {
      final room = await _repository.roomForAppointment(appointmentId);
      _room = room;
      await _subscription?.cancel();
      _subscription = _repository.messages(room.chatId).listen(
            (messages) => emit(
              ChatLoaded(
                room: room,
                messages: messages,
                currentUserId: _repository.currentFirebaseUid ?? '',
              ),
            ),
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
      await _repository.sendMessage(chatId: room.chatId, text: text);
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
