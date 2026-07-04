import 'package:afiete/feature/chat/data/datasources/chat_remote_datasource.dart';
import 'package:afiete/feature/chat/data/models/chat_message_model.dart';
import 'package:afiete/feature/chat/data/models/chat_room_model.dart';

class ChatRepository {
  const ChatRepository(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;

  Future<ChatRoomModel> roomForCourse(String courseId) {
    return _remoteDataSource.roomForCourse(courseId);
  }

  Stream<List<ChatMessageModel>> messages(String courseId) {
    return _remoteDataSource.messages(courseId);
  }

  Future<void> sendMessage({
    required String courseId,
    required String text,
  }) {
    return _remoteDataSource.sendMessage(
      courseId: courseId,
      text: text,
    );
  }

  String? get currentFirebaseUid => _remoteDataSource.currentFirebaseUid;
}
