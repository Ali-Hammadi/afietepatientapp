// lib/features/chat/data/datasources/chat_remote_data_source.dart
import 'package:afiete/core/network/api_endpoints.dart';
import 'package:afiete/feature/chat/data/models/chat_message_model.dart'
    show ChatMessageModel;
import 'package:afiete/feature/chat/data/models/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/chat_room.dart';
import '../../domain/entities/chat_message.dart';

abstract class ChatRemoteDataSource {
  Future<ChatRoom> getRoomForAppointment(String appointmentId);
  Stream<List<ChatMessage>> getMessagesStream(String chatId);
  Future<void> sendMessage(
      {required String chatId, required String senderId, required String text});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl({
    required this.dio,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final Dio dio;
  final FirebaseFirestore _firestore;

  @override
  Future<ChatRoom> getRoomForAppointment(String appointmentId) async {
    final response = await dio.get(ApiEndpoints.chatMessages);
    return ChatRoomModel.fromJson(_normalizeMap(response.data));
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final chatRef = _firestore.collection('chats').doc(chatId);
    await chatRef.set(
        {'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));

    // 🔴 نستخدم senderId الممرر، والدور هو 'patient'
    await chatRef.collection('messages').add({
      'senderId': senderId,
      'senderRole': 'patient',
      'text': cleanText,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await chatRef.set({
      'lastMessage': cleanText,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    }, SetOptions(merge: true));
  }

  @override
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(ChatMessageModel.fromSnapshot)
            .where((message) => message.text.trim().isNotEmpty)
            .toList());
  }

  Map<String, dynamic> _normalizeMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map)
      return data.map((key, value) => MapEntry(key.toString(), value));
    return const <String, dynamic>{};
  }
}
