// lib/features/chat/presentation/screens/chat_screen.dart
import 'package:afiete/core/constants/app_colors.dart';
import 'package:afiete/feature/chat/data/datasources/chat_remote_datasource.dart';
import 'package:afiete/feature/chat/domain/usecases/chat_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.appointmentId,
    required this.doctorName,
  });

  final String appointmentId;
  final String doctorName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatCubit cubit;
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final repository = ChatRepositoryImpl(
      ChatRemoteDataSourceImpl(dio: Dio()),
    );

    cubit = ChatCubit(
      getChatRoom: GetChatRoom(repository),
      getMessagesStream: GetMessagesStream(repository),
      sendMessage: SendMessage(repository),
    )..openAppointmentChat(widget.appointmentId);
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    cubit.close();
    super.dispose();
  }

  Future<void> _send() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();
    await cubit.send(text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(
          // إزالة context.t واستبدالها بنص عادي
          title: Text(
            widget.doctorName.trim().isEmpty ? 'Chat' : widget.doctorName,
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<ChatCubit, ChatState>(
            listener: (context, state) {
              if (state is ChatLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!scrollController.hasClients) return;
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  );
                });
              }
            },
            builder: (context, state) {
              if (state is ChatLoading || state is ChatInitial) {
                return Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }
              if (state is ChatError) {
                return _ChatMessagePanel(
                  icon: Icons.error_outline,
                  message: state.message,
                  onRetry: () =>
                      cubit.openAppointmentChat(widget.appointmentId),
                );
              }
              if (state is! ChatLoaded) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  Expanded(
                    child: state.messages.isEmpty
                        ? const _ChatMessagePanel(
                            icon: Icons.chat_bubble_outline,
                            message: 'No messages yet.',
                          )
                        : ListView.separated(
                            controller: scrollController,
                            // استخدام أرقام عادية بدلاً من automaticWidth
                            padding: const EdgeInsets.all(16.0),
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              return _MessageBubble(
                                message: message,
                                isMe: message.senderId == state.currentUserId,
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10.0),
                            itemCount: state.messages.length,
                          ),
                  ),
                  _Composer(controller: messageController, onSend: _send),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==================== الـ Widgets الخاصة ====================

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  // استخدام الكيان الخاص بك مباشرة بدلاً من dynamic
  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isMe
        ? AppColors.primaryColor
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isMe ? AppColors.whiteColor : theme.colorScheme.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 285.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                if (message.createdAt != null) ...[
                  const SizedBox(height: 5.0),
                  Text(
                    _time(message.createdAt!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _time(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  prefixIcon: Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10.0),
            IconButton.filled(
              onPressed: onSend,
              icon: const Icon(Icons.send_outlined),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessagePanel extends StatelessWidget {
  const _ChatMessagePanel({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 42.0,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14.0),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
