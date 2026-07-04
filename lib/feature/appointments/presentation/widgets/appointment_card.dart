import 'package:afiete/core/assets/icon_image_links.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:afiete/feature/appointments/domain/constants/session_type.dart';
import 'package:afiete/feature/appointments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/chat/presentation/navigator/chat_navigator.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomAppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final DoctorEntity? doctor;
  final bool isPast;
  final bool isCanceled;
  final VoidCallback? onAddReview;
  final VoidCallback? onBookAgain;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final VoidCallback? onJoinSession;

  const CustomAppointmentCard({
    super.key,
    required this.appointment,
    required this.isPast,
    this.isCanceled = false,
    this.doctor,
    this.onAddReview,
    this.onBookAgain,
    this.onReschedule,
    this.onCancel,
    this.onJoinSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateText = DateFormat('EEE, dd MMM yyyy - hh:mm a')
        .format(appointment.scheduledAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        side: BorderSide(
          color: isCanceled
              ? colorScheme.error.withValues(alpha: 0.5)
              : colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: doctor?.imageUrl != null
                      ? NetworkImage(doctor!.imageUrl!)
                      : const AssetImage(ImageLinks.appIcon) as ImageProvider,
                  radius: 30,
                  backgroundColor:
                      colorScheme.primaryContainer.withValues(alpha: 0.35),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      doctor?.name ?? appointment.doctorName,
                      style: AppStyles.headingSmall,
                    ),
                    subtitle: Text(
                      doctor?.specialization == null
                          ? SettingsStrings.specialistLabelInAppointment
                          : SettingsStrings.specialtyLabel(
                              doctor!.specialties.firstOrNull ??
                                  doctor!.specialization,
                            ),
                      style: AppStyles.bodyMedium,
                    ),
                  ),
                ),
                if (!isCanceled && onCancel != null)
                  IconButton(
                    onPressed: onCancel,
                    icon: Icon(Icons.close_rounded, color: colorScheme.error),
                    tooltip: SettingsStrings.cancelAction,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 32, height: 32),
                  ),
              ],
            ),
            if (isCanceled)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    SettingsStrings.canceled,
                    style: AppStyles.bodySmall.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppStyles.padding),
              decoration: BoxDecoration(
                color: isCanceled
                    ? colorScheme.errorContainer.withValues(alpha: 0.2)
                    : colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateText, style: AppStyles.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    SettingsStrings.durationMinutesLabel(
                        appointment.durationSlots * 30),
                    style: AppStyles.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  SessionType.displayWithIcon(
                    appointment.sessionType,
                    textStyle: AppStyles.bodySmall,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            if (!isCanceled)
              Padding(
                padding: const EdgeInsets.all(AppStyles.padding),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: [
                    if (isPast && onAddReview != null)
                      CustomButton(
                        widget: Text(
                          SettingsStrings.addReview,
                          style: AppStyles.bodySmall
                              .copyWith(color: colorScheme.onPrimary),
                        ),
                        onPressed: onAddReview,
                      ),
                    if (isPast)
                      CustomButton(
                        widget: Text(
                          SettingsStrings.bookAgain,
                          style: AppStyles.bodySmall
                              .copyWith(color: colorScheme.onPrimary),
                        ),
                        onPressed: onBookAgain,
                      )
                    else ...[
                      CustomButton(
                        widget: Text(
                          SettingsStrings.joinSession,
                          style: AppStyles.bodySmall
                              .copyWith(color: colorScheme.onPrimary),
                        ),
                        onPressed:
                            onJoinSession ?? () => _handleJoinSession(context),
                      ),
                      CustomButton(
                        widget: Text(
                          SettingsStrings.reschedule,
                          style: AppStyles.bodySmall
                              .copyWith(color: colorScheme.onPrimary),
                        ),
                        onPressed: onReschedule,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

// في نهاية الملف، عدّل هذه الدالة:
  void _handleJoinSession(BuildContext context) {
    // ✅ استخدام treatmentCourseId بدلاً من appointmentId
    if (appointment.treatmentCourseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Treatment course not found for this appointment.'),
        ),
      );
      return;
    }

    ChatNavigator.openCourseChat(
      context,
      courseId: appointment.treatmentCourseId, // ✅ تغيير هنا
      doctorName: doctor?.name ?? appointment.doctorName,
      currentUserId: appointment.patientUsername,
    );
  }
}
