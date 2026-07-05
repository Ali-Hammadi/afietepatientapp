// lib/feature/courses/presentation/widgets/active_course_card.dart
import 'package:afiete/core/assets/icon_image_links.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:afiete/feature/cources/domain/entities/cources_entities.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActiveCourseCard extends StatelessWidget {
  final CourseEntity course;
  final DoctorEntity? doctor;
  final VoidCallback? onViewChat;
  final VoidCallback? onEndCourse;

  const ActiveCourseCard({
    super.key,
    required this.course,
    this.doctor,
    this.onViewChat,
    this.onEndCourse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final startedText = course.startedAt != null
        ? DateFormat('dd MMM yyyy').format(course.startedAt!)
        : 'N/A';

    // ✅ ألوان متناسبة مع الـ theme
    final isDark = theme.brightness == Brightness.dark;
    final gradientStart = colorScheme.primary;
    final gradientEnd = colorScheme.primary.withValues(alpha: 0.75);
    final textPrimary = Colors.white;
    final textSecondary = Colors.white.withValues(alpha: 0.85);
    final chipBg = Colors.white.withValues(alpha: isDark ? 0.18 : 0.25);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.padding * 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header - Status Badge
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        course.status.displayName,
                        style: AppStyles.bodySmall.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.favorite_rounded,
                  color: textPrimary.withValues(alpha: 0.9),
                  size: 22,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ✅ Doctor Info
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
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
                        doctor?.name ?? 'Your Doctor',
                        style: AppStyles.headingSmall.copyWith(
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor?.specialization ?? 'Specialist',
                        style: AppStyles.bodySmall.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.25)),
            const SizedBox(height: 12),

            // ✅ Stats
            Row(
              children: [
                _StatItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Started',
                  value: startedText,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  icon: Icons.medical_services_outlined,
                  label: 'Sessions',
                  value: '${course.sessionsCount}',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ✅ Actions
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    widget: Text(
                      'View Chat',
                      style: AppStyles.bodySmall.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: onViewChat,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEndCourse,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  tooltip: 'End Course',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: AppStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
