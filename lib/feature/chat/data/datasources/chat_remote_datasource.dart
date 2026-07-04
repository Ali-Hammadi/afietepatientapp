import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/chat/data/models/chat_message_model.dart';
import 'package:afiete/feature/chat/data/models/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ChatRemoteDataSource {
  Future<ChatRoomModel> roomForCourse(String courseId);
  Stream<List<ChatMessageModel>> messages(String courseId);
  Future<void> sendMessage({
    required String courseId,
    required String text,
  });
  String? get currentFirebaseUid;
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({
    required this.dio,
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final Dio dio;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  bool _isFirebaseSignedIn = false;

  @override
  String? get currentFirebaseUid => _firebaseAuth.currentUser?.uid;

  @override
  Future<ChatRoomModel> roomForCourse(String courseId) async {
    await _ensureFirebaseSignedIn();

    final response = await dio.get(ApiEndpoints.courseChatRoom(courseId));
    return ChatRoomModel.fromJson(_normalizeMap(response.data));
  }

  @override
  Stream<List<ChatMessageModel>> messages(String courseId) {
    return _firestore
        .collection('treatment_courses')
        .doc(courseId)
        .collection('messages')
        .orderBy('created_at', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ChatMessageModel.fromSnapshot)
              .where((message) => message.text.trim().isNotEmpty)
              .toList(),
        );
  }

  @override
  Future<void> sendMessage({
    required String courseId,
    required String text,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await _ensureFirebaseSignedIn();
    final uid = currentFirebaseUid;
    if (uid == null || uid.isEmpty) {
      throw Exception('Firebase user is not signed in.');
    }

    final courseRef = _firestore.collection('treatment_courses').doc(courseId);

    await courseRef.collection('messages').add({
      'sender_uid': uid,
      'text': cleanText,
      'media_url': '',
      'media_type': '',
      'created_at': FieldValue.serverTimestamp(),
      'is_read': false,
    });

    // ✅ توحيد اسم الحقل
    await courseRef.update({
      'last_message': cleanText,
      'last_message_at': FieldValue.serverTimestamp(),
      'last_sender_uid': uid, // ✅ تغيير من last_sender_username
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _ensureFirebaseSignedIn() async {
    if (_isFirebaseSignedIn && _firebaseAuth.currentUser != null) return;

    final response = await dio.post(ApiEndpoints.firebaseChatToken);
    final data = _normalizeMap(response.data);
    final token = data['token']?.toString();

    if (token == null) throw Exception('Firebase token is missing.');

    await _firebaseAuth.signInWithCustomToken(token);
    _isFirebaseSignedIn = true;
  }

  Map<String, dynamic> _normalizeMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }
}
