import 'package:afiete/core/constants/app_colors.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:flutter/material.dart';

abstract class SessionType {
  static const String textChat = 'chat';
  static const String voiceCall = 'voice';
  static const String videoCall = 'video';

  static const List<String> all = [textChat, voiceCall, videoCall];

  static String displayName(String type) {
    switch (type) {
      case textChat:
        return SettingsStrings.textChatTitle;
      case voiceCall:
        return SettingsStrings.voiceCallTitle;
      case videoCall:
        return SettingsStrings.videoCallTitle;
      default:
        return type;
    }
  }

  static IconData icon(String type) {
    switch (type) {
      case textChat:
        return Icons.chat_bubble_outline;
      case voiceCall:
        return Icons.call_outlined;
      case videoCall:
        return Icons.videocam_outlined;
      default:
        return Icons.info_outline;
    }
  }

  static Widget displayWithIcon(String type, {TextStyle? textStyle}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon(type), size: 24, color: AppColors.primaryColor),
        const SizedBox(width: 6),
        Text(displayName(type), style: textStyle),
      ],
    );
  }
}
