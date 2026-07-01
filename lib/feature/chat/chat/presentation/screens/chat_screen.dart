import 'package:afiete/core/constants/app_colors.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/feature/chat/chat/data/model/chat_model.dart';
import 'package:afiete/feature/chat/chat/data/repositories/chat_repository.dart';
import 'package:afiete/feature/chat/chat/data/services/chat_services.dart';
import 'package:afiete/feature/chat/chat/presentation/cubit/chat_cubit.dart';
import 'package:afiete/feature/chat/presentation/cubit/chat_cubit.dart'
    hide ChatCubit;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
    this.repository,
  });

  final String appointmentId;
  final String patientName;
  final ChatRepository? repository;

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

    cubit = ChatCubit(
      widget.repository ?? ChatRepository(ChatService(dio: sl<Dio>())),
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
          title: Text(
            widget.patientName.trim().isEmpty ? ('Chat') : widget.patientName,
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
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
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
                            padding: EdgeInsets.all((16)),
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              return _MessageBubble(
                                message: message,
                                isMe: message.senderId == state.currentUserId,
                              );
                            },
                            separatorBuilder: (_, __) => SizedBox(height: (10)),
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessageModel message;
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
        constraints: BoxConstraints(maxWidth: (285)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular((8)),
          ),
          child: Padding(
            padding: EdgeInsets.all((12)),
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
                  SizedBox(height: (5)),
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
        padding: EdgeInsets.all((12)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: ('Type a message...'),
                  prefixIcon: Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: (10)),
            IconButton.filled(
              onPressed: onSend,
              icon: const Icon(Icons.send_outlined),
              tooltip: ('Send'),
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
        padding: EdgeInsets.all((24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: (42),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: (10)),
            Text(
              (message),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: (14)),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_outlined),
                label: Text(('Refresh')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
