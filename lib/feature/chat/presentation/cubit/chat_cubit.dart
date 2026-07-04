import 'dart:async';
import 'package:afiete/feature/chat/data/models/chat_message_model.dart';
import 'package:afiete/feature/chat/data/models/chat_room_model.dart';
import 'package:afiete/feature/chat/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(const ChatInitial());

  final ChatRepository _repository;
  StreamSubscription<List<ChatMessageModel>>? _subscription;
  ChatRoomModel? _room;

  Future<void> openCourseChat(String courseId) async {
    emit(const ChatLoading());
    try {
      final room = await _repository.roomForCourse(courseId);
      _room = room;

      await _subscription?.cancel();
      _subscription = _repository.messages(room.courseId).listen(
            (messages) => emit(
              ChatLoaded(
                room: room,
                messages: messages,
                currentUserId: _repository.currentFirebaseUid ?? '',
              ),
            ),
            onError: (Object error) => emit(ChatError(_cleanError(error))),
          );
    } catch (error) {
      emit(ChatError(_cleanError(error)));
    }
  }

  Future<void> send(String text) async {
    final room = _room;
    if (room == null || room.isArchived) return;

    try {
      await _repository.sendMessage(
        courseId: room.courseId,
        text: text,
      );
    } catch (error) {
      emit(ChatError(_cleanError(error)));
    }
  }

  String _cleanError(Object error) {
    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.substring('Exception: '.length);
    }
    return text;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
