import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/di/injection_container.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/feature/appointments/presentation/cubits/appointments_cubit.dart';
import 'package:afiete/feature/appointments/presentation/widgets/appointment_card.dart';
import 'package:afiete/feature/appointments/domain/entities/appointment_entity.dart';
import 'package:afiete/feature/chat/presentation/helpers/chat_session_navigator.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/sessions/presentation/cubits/sessions_cubit.dart';
import 'package:afiete/feature/sessions/presentation/widgets/review_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedTabIndex = 0; // 0: Upcoming, 1: Past, 2: Canceled

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<AppointmentsCubit>();
      if (cubit.state is AppointmentsInitial) {
        cubit.loadAppointments();
      }
      cubit.startDoctorRescheduleListener();
    });
  }

  late AppointmentsCubit _appointmentsCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appointmentsCubit = context.read<AppointmentsCubit>();
  }

  @override
  void dispose() {
    _appointmentsCubit.stopDoctorRescheduleListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTabSelector(theme: theme, colorScheme: colorScheme),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<AppointmentsCubit, AppointmentsState>(
                builder: _buildStateBody,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector({
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.all(AppStyles.padding / 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildTabItem(
              title: SettingsStrings.upcoming,
              isSelected: _selectedTabIndex == 0,
              colorScheme: colorScheme,
              onTap: () => setState(() => _selectedTabIndex = 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem(
              title: SettingsStrings.past,
              isSelected: _selectedTabIndex == 1,
              colorScheme: colorScheme,
              onTap: () => setState(() => _selectedTabIndex = 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabItem(
              title: SettingsStrings.canceled,
              isSelected: _selectedTabIndex == 2,
              colorScheme: colorScheme,
              onTap: () => setState(() => _selectedTabIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.45)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      ),
      padding: const EdgeInsets.all(AppStyles.padding / 2),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: AppStyles.headingSmall.copyWith(
            color: isSelected ? colorScheme.onPrimaryContainer : null,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStateBody(BuildContext context, AppointmentsState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state is AppointmentsLoading || state is AppointmentsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AppointmentsError) {
      return _buildErrorState(
        context: context,
        colorScheme: colorScheme,
        message: state.message,
      );
    }

    if (state is AppointmentsLoaded) {
      return _buildLoadedState(context: context, state: state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorState({
    required BuildContext context,
    required ColorScheme colorScheme,
    required String message,
  }) {
    final lowerMessage = message.toLowerCase();
    final isConnectionIssue = lowerMessage.contains('internet') ||
        lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('socket');

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isConnectionIssue
                  ? Icons.wifi_off_rounded
                  : Icons.error_outline_rounded,
              size: 42,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 10),
            Text(
              isConnectionIssue
                  ? SettingsStrings
                      .noInternetConnectionPleaseReconnectAndTryAgain
                  : message,
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                context.read<AppointmentsCubit>().loadAppointments();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(SettingsStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState({
    required BuildContext context,
    required AppointmentsLoaded state,
  }) {
    List<AppointmentEntity> filteredAppointments;

    switch (_selectedTabIndex) {
      case 0: // Upcoming
        filteredAppointments = state.upcomingAppointments;
        break;
      case 1: // Past
        filteredAppointments = [
          ...state.pastAppointments,
          ...state.missedAppointments,
        ].where((appointment) {
          final statusLower = appointment.status.toLowerCase();
          return statusLower != 'cancelled' && statusLower != 'canceled';
        }).toList();
        break;
      case 2: // Canceled
        filteredAppointments = state.canceledAppointments;
        break;
      default:
        filteredAppointments = [];
    }

    if (filteredAppointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () {
          return context.read<AppointmentsCubit>().loadAppointments();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text(
                _selectedTabIndex == 0
                    ? SettingsStrings.noUpcomingAppointments
                    : _selectedTabIndex == 1
                        ? SettingsStrings.noPastAppointments
                        : SettingsStrings.noCanceledAppointments,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return context.read<AppointmentsCubit>().loadAppointments();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredAppointments.length,
        itemBuilder: (context, index) {
          final appointment = filteredAppointments[index];
          final matchedDoctor = _findDoctorForAppointment(
            state.doctors,
            appointment.doctorUsername,
          );
          final isCompleted = appointment.status.toLowerCase() == 'completed';
          final canReview = isCompleted;

          return CustomAppointmentCard(
            doctor: matchedDoctor,
            appointment: appointment,
            isPast: _selectedTabIndex == 1,
            isCanceled: _selectedTabIndex == 2,
            onAddReview: _selectedTabIndex != 1 || !canReview
                ? null
                : () => _showReviewSheet(
                      appointmentId: appointment.appointmentId,
                      hasNextSession: appointment.hasNextSession,
                    ),
            onBookAgain: _selectedTabIndex != 1
                ? null
                : () => _handleBookAgain(
                      doctor: matchedDoctor ??
                          _buildFallbackDoctor(appointment: appointment),
                    ),
            onReschedule: _selectedTabIndex != 0
                ? null
                : () => _handleReschedule(
                      appointmentId: appointment.appointmentId,
                      doctor: matchedDoctor ??
                          _buildFallbackDoctor(appointment: appointment),
                    ),
            onCancel: _selectedTabIndex == 0
                ? () => _confirmCancel(context,
                    appointmentId: appointment.appointmentId)
                : null,
            onJoinSession: _selectedTabIndex == 0
                ? () => _handleJoinSession(appointment)
                : null,
          );
        },
      ),
    );
  }

  DoctorEntity? _findDoctorForAppointment(
    List<DoctorEntity>? doctors,
    String doctorUsername,
  ) {
    final list = doctors ?? const <DoctorEntity>[];

    for (final doctor in list) {
      if (doctor.doctorUsername == doctorUsername) {
        return doctor;
      }
    }

    return null;
  }

  DoctorEntity _buildFallbackDoctor({required AppointmentEntity appointment}) {
    return DoctorEntity(
      doctorUsername: appointment.doctorUsername,
      name: appointment.doctorName,
      specialties: const [],
    );
  }

  Future<void> _handleReschedule({
    required dynamic appointmentId,
    required DoctorEntity doctor,
  }) async {
    final result = await Navigator.pushNamed<Map<String, dynamic>?>(
      context,
      MyRoutes.rescheduleSessionScreen,
      arguments: {'doctor': doctor},
    );

    if (result == null || !mounted) {
      return;
    }

    final selectedTime = result['selectedTime'] as DateTime?;

    if (selectedTime == null) return;

    final success = await context
        .read<AppointmentsCubit>()
        .rescheduleAppointment(
            appointmentId: appointmentId,
            doctorUsername: doctor.doctorUsername,
            newDate: selectedTime,
            slotStart:
                selectedTime.toIso8601String().split('T')[1].substring(0, 5),
            slotEnd: selectedTime
                .add(const Duration(minutes: 30))
                .toIso8601String()
                .split('T')[1]
                .substring(0, 5));

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SettingsStrings.sessionRescheduledSuccessfully)),
      );
    }
  }

  void _handleJoinSession(AppointmentEntity appointment) {
    ChatSessionNavigator.openFromAppointment(
      context,
      appointment,
      doctorName: appointment.doctorName,
      currentUserId: appointment.patientUsername,
    );
  }

  Future<void> _handleBookAgain({required DoctorEntity doctor}) async {
    await Navigator.pushNamed(
      context,
      MyRoutes.bookSessionScreen,
      arguments: doctor,
    );
  }

  void _showReviewSheet({
    required dynamic appointmentId,
    required bool hasNextSession,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<SessionsCubit>(
        create: (_) => sl<SessionsCubit>(),
        child: CustomReviewBottomSheet(
          appointmentId: appointmentId,
          hasNextSession: hasNextSession,
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, {required dynamic appointmentId}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(SettingsStrings.cancelSessionTitle),
        content: Text(SettingsStrings.cancelSessionQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(SettingsStrings.no),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context
                  .read<AppointmentsCubit>()
                  .cancelAppointment(appointmentId);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(SettingsStrings.sessionCancelled)),
                );
              }
            },
            child: Text(SettingsStrings.yesCancel),
          ),
        ],
      ),
    );
  }
}
