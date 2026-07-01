import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final int senderId;
  final String senderType; // doctor أو patient
  final String text;
  final Timestamp createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderType': senderType,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'],
      senderType: map['senderType'],
      text: map['text'],
      createdAt: map['createdAt'],
    );
  }
}
