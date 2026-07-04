import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.senderUid,
    required this.text,
    this.mediaUrl,
    this.mediaType,
    this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String senderUid;
  final String text;
  final String? mediaUrl;
  final String? mediaType;
  final DateTime? createdAt;
  final bool isRead;

  factory ChatMessageModel.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final createdAt = data['created_at'];

    return ChatMessageModel(
      id: snapshot.id,
      senderUid: data['sender_uid']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      mediaUrl: data['media_url']?.toString(),
      mediaType: data['media_type']?.toString(),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      isRead: data['is_read'] == true,
    );
  }
}
