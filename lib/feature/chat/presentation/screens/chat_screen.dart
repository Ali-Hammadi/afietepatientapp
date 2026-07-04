// lib/feature/chat/presentation/screens/chat_screen.dart
import 'package:afiete/core/constants/app_colors.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/feature/chat/data/models/chat_message_model.dart';
import 'package:afiete/feature/chat/data/repositories/course_repository.dart';
import 'package:afiete/feature/chat/presentation/cubit/chat_cubit.dart';
import 'package:afiete/feature/chat/presentation/widget/continue_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afiete/feature/chat/data/repositories/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.courseId,
    this.patientName,
    this.doctorName,
    this.chatRepository,
  }) : assert(
          patientName != null || doctorName != null,
          'Either patientName or doctorName must be provided',
        );

  final String courseId;
  final String? patientName;
  final String? doctorName;
  final ChatRepository? chatRepository;

  String get otherUserName => patientName ?? doctorName ?? 'Chat';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatCubit cubit;
  late final CourseRepository courseRepository;
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  bool _hasShownContinueDialog = false;

  @override
  void initState() {
    super.initState();

    // ✅ استخدام DI بدلاً من DioClient
    final chatRepo = widget.chatRepository ?? sl<ChatRepository>();

    cubit = ChatCubit(chatRepo)..openCourseChat(widget.courseId);

    // ✅ استخدام DI لـ CourseRepository
    courseRepository = sl<CourseRepository>();

    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    try {
      print('🔥 Testing Firebase connection...');
      print('📱 Course ID: ${widget.courseId}');

      // ✅ الخطوة 1: تسجيل الدخول أولاً
      final cubit = context.read<ChatCubit>();
      await cubit.ensureSignedIn(); // ✅ استدعاء الدالة الجديدة

      // ✅ الخطوة 2: التحقق من Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      print('👤 Current User: ${user?.uid}');

      if (user == null) {
        print('❌ User not signed in to Firebase!');
        return;
      }

      // ✅ الخطوة 3: الآن اقرأ Firestore
      final doc = await FirebaseFirestore.instance
          .collection('treatment_courses')
          .doc(widget.courseId)
          .get();

      print('✅ Course data: ${doc.data()}');
      print('✅ doctor_uid: ${doc.data()?['doctor_uid']}');
      print('✅ patient_uid: ${doc.data()?['patient_uid']}');
      print('✅ Can read: true');
    } catch (e) {
      print('❌ Error: $e');
      if (e is FirebaseException) {
        print('❌ Code: ${e.code}');
        print('❌ Message: ${e.message}');
      }
    }
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

  void _showContinueCourseDialog() {
    if (_hasShownContinueDialog) return;
    _hasShownContinueDialog = true;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => ContinueCourseBottomSheet(
        onContinue: () async {
          final courseId = int.tryParse(widget.courseId);
          if (courseId == null) return;

          final success = await courseRepository.requestContinue(courseId);
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? ('تم إرسال طلب المتابعة بنجاح')
                    : ('فشل في إرسال الطلب'),
              ),
            ),
          );
        },
        onDecline: () async {
          final courseId = int.tryParse(widget.courseId);
          if (courseId == null) return;

          final success = await courseRepository.declineContinue(courseId);
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success ? ('تم إنهاء الكورس العلاجي') : ('فشل في إنهاء الكورس'),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.otherUserName.trim().isEmpty
                ? ('Chat')
                : widget.otherUserName,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: ('End Course'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(('End Course')),
                    content:
                        Text(('Are you sure you want to end this course?')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(('Cancel')),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          final courseId = int.tryParse(widget.courseId);
                          if (courseId != null) {
                            final success =
                                await courseRepository.endCourse(courseId);
                            if (mounted && success) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Text(('End')),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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

                  if (state.room.isArchived && !_hasShownContinueDialog) {
                    _showContinueCourseDialog();
                  }
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
                  onRetry: () => cubit.openCourseChat(widget.courseId),
                );
              }
              if (state is! ChatLoaded) {
                return const SizedBox.shrink();
              }

              final isArchived = state.room.isArchived;

              return Column(
                children: [
                  if (isArchived)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all((8)),
                      color: Colors.grey.shade200,
                      child: Text(
                        ('This course is archived. You can only read messages.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
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
                                isMe: message.senderUid == state.currentUserId,
                              );
                            },
                            separatorBuilder: (_, __) => SizedBox(height: (10)),
                            itemCount: state.messages.length,
                          ),
                  ),
                  if (!isArchived)
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

// ... باقي الـ Widgets (_MessageBubble, _Composer, _ChatMessagePanel) تبقى كما هي ...
// ... باقي الـ Widgets (_MessageBubble, _Composer, _ChatMessagePanel) تبقى كما هي ...
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
        constraints: const BoxConstraints(maxWidth: 285),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 5),
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  prefixIcon: Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 42,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
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
