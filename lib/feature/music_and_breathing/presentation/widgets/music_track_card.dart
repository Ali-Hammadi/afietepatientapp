import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/feature/music_and_breathing/domain/entities/music_entity.dart';
import 'package:flutter/material.dart';

class MusicTrackCard extends StatelessWidget {
  final MusicEntity track;
  final bool isSelected;
  final VoidCallback onPlay;
  final int index; // مرر ترتيب الكرت ليعطي حركة تتابعية

  const MusicTrackCard({
    super.key,
    required this.track,
    required this.isSelected,
    required this.onPlay,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(40 * (1 - value), 0), // تأثير حركة انزلاقية من الجانب
          child: Opacity(
            opacity: value, // تأثير ظهور متلاشي ناعم
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.55)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          border: Border.all(
            color:
                isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(Icons.graphic_eq_rounded, color: colorScheme.primary),
          ),
          title: Text(
            track.title,
            style: AppStyles.bodyMedium.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${track.artist} • ${track.durationSeconds ~/ 60} min ${track.durationSeconds % 60}s',
              style: AppStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          trailing: IconButton(
            onPressed: onPlay,
            icon: Icon(
              isSelected ? Icons.play_circle_fill : Icons.play_circle_outline,
              size: 30,
              color: colorScheme.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
