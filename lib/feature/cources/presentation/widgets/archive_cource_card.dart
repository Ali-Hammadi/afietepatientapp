// lib/feature/courses/presentation/widgets/archived_course_card.dart
import 'package:afiete/core/assets/icon_image_links.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:afiete/feature/cources/domain/entities/cources_entities.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArchivedCourseCard extends StatelessWidget {
  final CourseEntity course;
  final DoctorEntity? doctor;
  final VoidCallback? onViewChat;
  final VoidCallback? onRequestContinue;

  const ArchivedCourseCard({
    super.key,
    required this.course,
    this.doctor,
    this.onViewChat,
    this.onRequestContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final endedText = course.endedAt != null
        ? DateFormat('dd MMM yyyy').format(course.endedAt!)
        : 'N/A';

    // ✅ ألوان متناسبة مع الـ theme
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor, // ✅ استخدام cardColor من الـ theme
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.padding),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      colorScheme.primaryContainer.withValues(alpha: 0.35),
                  backgroundImage: doctor?.imageUrl != null &&
                          doctor!.imageUrl!.isNotEmpty
                      ? NetworkImage(doctor!.imageUrl!)
                      : const AssetImage(ImageLinks.appIcon) as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor?.name ?? 'Doctor',
                        style: AppStyles.headingSmall.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor?.specialization ?? 'Specialist',
                        style: AppStyles.bodySmall.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Completed',
                    style: AppStyles.bodySmall.copyWith(
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: isDark ? 0.1 : 0.2),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: 'Ended: $endedText',
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.medical_services_outlined,
                  label: '${course.sessionsCount} sessions',
                  colorScheme: colorScheme,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    widget: Text(
                      'View Chat',
                      style: AppStyles.bodySmall.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    onPressed: onViewChat,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: CustomButton(
                    widget: Text(
                      'Request Continue',
                      style: AppStyles.bodySmall.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    onPressed:
                        course.continueRequested ? null : onRequestContinue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: AppStyles.bodySmall.copyWith(
                  fontSize: 11,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
