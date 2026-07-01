import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/feature/sessions/presentation/cubits/sessions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomReviewBottomSheet extends StatefulWidget {
  final dynamic appointmentId;
  final bool hasNextSession;

  const CustomReviewBottomSheet({
    super.key,
    required this.appointmentId,
    required this.hasNextSession,
  });

  @override
  State<CustomReviewBottomSheet> createState() =>
      _CustomReviewBottomSheetState();
}

class _CustomReviewBottomSheetState extends State<CustomReviewBottomSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onCommentChanged);
  }

  void _onCommentChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _commentController.removeListener(_onCommentChanged);
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            topEnd: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(SettingsStrings.addReview, style: AppStyles.headingMedium),
              const SizedBox(height: 20),
              Center(
                child: _StarRating(
                  rating: _rating,
                  onRatingChanged: (newRating) {
                    setState(() => _rating = newRating);
                  },
                ),
              ),
              if (!widget.hasNextSession) ...[
                const SizedBox(height: 24),
                Text(SettingsStrings.writeComment,
                    style: AppStyles.headingSmall),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 6,
                  scrollPadding: EdgeInsets.only(bottom: bottomInset + 24),
                  decoration: InputDecoration(
                    hintText: SettingsStrings.writeCommentHint,
                    hintStyle: AppStyles.bodySmall,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.45,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                const SizedBox(height: 24),
                Text(
                  'Stars only for sessions that still have a next session.',
                  style: AppStyles.bodySmall,
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _rating > 0
                      ? () async {
                          setState(() => _isSubmitting = true);

                          final success =
                              await context.read<SessionsCubit>().submitReview(
                                    appointmentId: widget.appointmentId,
                                    rating: _rating,
                                    comment: widget.hasNextSession
                                        ? null
                                        : _commentController.text.trim().isEmpty
                                            ? null
                                            : _commentController.text.trim(),
                                  );

                          if (!context.mounted) {
                            return;
                          }

                          setState(() => _isSubmitting = false);

                          if (success) {
                            Navigator.pop(context);
                          } else {
                            final state = context.read<SessionsCubit>().state;
                            final message = state is SessionsError
                                ? state.message
                                : 'Review could not be submitted.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        }
                      : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(SettingsStrings.submit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;

  const _StarRating({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 1; i <= 5; i++)
          GestureDetector(
            onTap: () => onRatingChanged(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                i <= rating ? Icons.star : Icons.star_outline,
                color: i <= rating ? Colors.yellow : colorScheme.outline,
                size: 40,
              ),
            ),
          ),
      ],
    );
  }
}
