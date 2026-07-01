import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/chat/chat/data/model/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  ChatService({
    required this.dio,
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final Dio dio;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<ChatRoomModel> roomForAppointment(String appointmentId) async {
    await ensureFirebaseSignedIn();
    final response = await dio.get(
      ApiEndpoints.appointmentChatRoom(appointmentId),
    );
    return ChatRoomModel.fromJson(_normalizeMap(response.data));
  }

  Future<void> ensureFirebaseSignedIn() async {
    if (_firebaseAuth.currentUser != null) return;
    final response = await dio.post(ApiEndpoints.firebaseChatToken);
    final token = _readString(_normalizeMap(response.data), const ['token']);
    if (token == null) {
      throw Exception('Firebase token is missing.');
    }
    await _firebaseAuth.signInWithCustomToken(token);
  }

  String? get currentFirebaseUid => _firebaseAuth.currentUser?.uid;

  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    await ensureFirebaseSignedIn();
    final uid = currentFirebaseUid;
    if (uid == null || uid.isEmpty) {
      throw Exception('Firebase user is not signed in.');
    }

    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final chatRef = _firestore.collection('chats').doc(chatId);
    await chatRef.set({
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'senderId': uid,
      'senderRole': 'doctor',
      'text': cleanText,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await chatRef.set({
      'lastMessage': cleanText,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': uid,
    }, SetOptions(merge: true));
  }

  Stream<List<ChatMessageModel>> messages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ChatMessageModel.fromSnapshot)
              .where((message) => message.text.trim().isNotEmpty)
              .toList(),
        );
  }

  Map<String, dynamic> _normalizeMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  String? _readString(Map source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return null;
  }
}
