// lib/feature/chat/presentation/navigation/chat_navigator.dart
import 'package:afiete/core/routes/app_route.dart';
import 'package:flutter/material.dart';

class ChatNavigator {
  const ChatNavigator._();

  static Future<void> openCourseChat(
    BuildContext context, {
    required String courseId,
    required String doctorName,
    required String currentUserId,
  }) {
    return Navigator.of(context).pushNamed(
      MyRoutes.chatScreen,
      arguments: ChatConversationArgs(
        courseId: courseId,
        doctorName: doctorName,
        currentUserId: currentUserId,
      ),
    );
  }
}
