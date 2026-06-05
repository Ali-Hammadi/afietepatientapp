import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:afiete/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:afiete/feature/appoinments/domain/constants/session_type.dart';
import 'package:afiete/feature/appoinments/presentation/cubits/appointments_cubit.dart';
import 'package:afiete/feature/doctors/domain/entites/doctor_entity.dart';
import 'package:afiete/feature/doctors/presentation/cubits/doctors_cubit.dart';
import 'package:afiete/feature/payment/domain/entities/payment_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum _BookingStep { date, time, duration, type }

class BookSessionScreen extends StatefulWidget {
  final DoctorEntity doctor;
  final bool rescheduleMode;

  const BookSessionScreen({
    super.key,
    required this.doctor,
    this.rescheduleMode = false,
  });

  @override
  State<BookSessionScreen> createState() => _BookSessionScreenState();
}

class _BookSessionScreenState extends State<BookSessionScreen> {
  _BookingStep _step = _BookingStep.date;
  DateTime? _selectedDate;
  DoctorTimeSlot? _selectedSlot;
  List<DoctorTimeSlot> _daySlots = const [];
  bool _isLoadingSlots = false;
  String? _slotsError;
  int? _selectedDurationSlots;
  String? _selectedSessionType;
  bool _isSubmitting = false;

  DateTime? get _selectedDateTime {
    if (_selectedSlot == null || _selectedDate == null) return null;
    return _selectedSlot!.toStartDateTime(_selectedDate!);
  }

  List<DateTime> get _nextDays {
    final today = DateUtils.dateOnly(DateTime.now());
    return List.generate(14, (i) => today.add(Duration(days: i)));
  }

  List<int> get _availableDurations {
    if (widget.doctor.availableDurations.isEmpty) {
      return const [1, 2];
    }
    final durations =
        widget.doctor.availableDurations.where((e) => e > 0).toList()..sort();
    return durations.isEmpty ? const [1, 2] : durations;
  }

  List<String> get _availableSessionTypes {
    if (widget.doctor.availableSessionTypes.isEmpty) {
      return SessionType.all;
    }
    final supported = widget.doctor.availableSessionTypes
        .where((e) => SessionType.all.contains(e))
        .toList();
    return supported.isEmpty ? SessionType.all : supported;
  }

  Future<void> _onDateSelected(DateTime day) async {
    if (_selectedDate != null &&
        DateUtils.isSameDay(_selectedDate, day) &&
        _daySlots.isNotEmpty) {
      return;
    }

    setState(() {
      _selectedDate = day;
      _selectedSlot = null;
      _daySlots = const [];
      _isLoadingSlots = true;
      _slotsError = null;
    });

    final username = widget.doctor.username ?? widget.doctor.id;
    final slots =
        await context.read<DoctorsCubit>().fetchSlotsForDate(username, day);

    if (!mounted) return;

    setState(() {
      _daySlots = slots;
      _isLoadingSlots = false;
    });
  }

  bool get _canContinue {
    switch (_step) {
      case _BookingStep.date:
        return _selectedDate != null &&
            _daySlots.isNotEmpty &&
            !_isLoadingSlots;
      case _BookingStep.time:
        return _selectedSlot != null;
      case _BookingStep.duration:
        return _selectedDurationSlots != null;
      case _BookingStep.type:
        return _selectedSessionType != null && !_isSubmitting;
    }
  }

  Future<void> _onContinuePressed() async {
    switch (_step) {
      case _BookingStep.date:
        setState(() => _step = _BookingStep.time);
        return;
      case _BookingStep.time:
        setState(() => _step = _BookingStep.duration);
        return;
      case _BookingStep.duration:
        setState(() => _step = _BookingStep.type);
        return;
      case _BookingStep.type:
        await _submitBooking();
        return;
    }
  }

  Future<void> _submitBooking() async {
    final scheduledAt = _selectedDateTime;
    if (scheduledAt == null ||
        _selectedDurationSlots == null ||
        _selectedSessionType == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    if (widget.rescheduleMode) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.pop(context, scheduledAt);
      return;
    }

    final authState = context.read<AuthCubit>().state;
    String patientId = 'unknown-patient';
    if (authState is AuthLoaded) {
      patientId = authState.user.username;
    } else if (authState is AuthProfileUpdated) {
      patientId = authState.user.username;
    }

    final cubit = context.read<AppointmentsCubit>();
    await cubit.createBookingDraft(
      doctorId: widget.doctor.id,
      patientId: patientId,
      doctorName: widget.doctor.name,
      scheduledAt: scheduledAt,
      durationSlots: _selectedDurationSlots!,
      consultationFee: widget.doctor.consultationFee,
      sessionType: _selectedSessionType!,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final state = cubit.state;
    if (state is AppointmentsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(SettingsStrings.bookingDraftCreatedSuccessfully)),
    );

    final amount = widget.doctor.consultationFee.getFeeBySType(
      _selectedSessionType!,
    );

    Navigator.pushNamed(
      context,
      MyRoutes.paymentScreen,
      arguments: PaymentRequestEntity(
        doctorId: widget.doctor.id,
        patientId: patientId,
        doctorName: widget.doctor.name,
        scheduledAt: scheduledAt,
        durationSlots: _selectedDurationSlots!,
        sessionType: _selectedSessionType!,
        amount: amount,
        currency: 'USD',
        method: PaymentMethod.card,
      ),
    );
  }

  void _onBack() {
    switch (_step) {
      case _BookingStep.date:
        Navigator.pop(context);
        return;
      case _BookingStep.time:
        setState(() => _step = _BookingStep.date);
        return;
      case _BookingStep.duration:
        setState(() => _step = _BookingStep.time);
        return;
      case _BookingStep.type:
        setState(() => _step = _BookingStep.duration);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBack,
        ),
        title: Text(
          widget.rescheduleMode
              ? SettingsStrings.reschedule
              : SettingsStrings.bookYourSessionTitle,
          style: AppStyles.headingMedium,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: _StepIndicator(
            current: _step.index,
            total: _BookingStep.values.length,
            color: colorScheme.primary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_titleForStep(_step), style: AppStyles.headingMedium),
            const SizedBox(height: 4),
            if (_step == _BookingStep.time && _selectedDate != null)
              Text(
                DateFormat('EEE, dd MMM yyyy', localeCode).format(
                  _selectedDate!,
                ),
                style: AppStyles.bodySmall,
              ),
            const SizedBox(height: 14),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildStepContent(localeCode),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              widget: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      _step == _BookingStep.type
                          ? (widget.rescheduleMode
                              ? SettingsStrings.reschedule
                              : SettingsStrings.continueToPayment)
                          : SettingsStrings.continueTextShort,
                      style: AppStyles.headingSmall.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
              onPressed: _canContinue ? _onContinuePressed : null,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(String localeCode) {
    switch (_step) {
      case _BookingStep.date:
        return _buildDateStep(localeCode);
      case _BookingStep.time:
        return _buildTimeStep(localeCode);
      case _BookingStep.duration:
        return _buildDurationStep();
      case _BookingStep.type:
        return _buildTypeStep();
    }
  }

  Widget _buildDateStep(String localeCode) {
    final days = _nextDays;
    return ListView.separated(
      key: const ValueKey('date-step'),
      itemCount: days.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final day = days[index];
        final isSelected =
            _selectedDate != null && DateUtils.isSameDay(_selectedDate, day);
        final isToday = DateUtils.isSameDay(day, DateTime.now());

        Widget? trailing;
        if (isSelected) {
          if (_isLoadingSlots) {
            trailing = SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (_daySlots.isEmpty) {
            trailing = Text(
              'No slots',
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            );
          } else {
            trailing = Text(
              '${_daySlots.length} slots',
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        }

        return _OptionCard(
          title: DateFormat('EEEE, dd MMM yyyy', localeCode).format(day),
          subtitle: isToday ? 'Today' : '',
          isSelected: isSelected,
          trailing: trailing,
          onTap: () => _onDateSelected(day),
        );
      },
    );
  }

  Widget _buildTimeStep(String localeCode) {
    if (_daySlots.isEmpty) {
      return Center(
        key: const ValueKey('time-step-empty'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 44,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 10),
            Text(
              SettingsStrings.noAvailableTimesForThisDate,
              textAlign: TextAlign.center,
              style: AppStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      key: const ValueKey('time-step'),
      itemCount: _daySlots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, index) {
        final slot = _daySlots[index];
        final isSelected = _selectedSlot == slot;
        return _ChipCard(
          label: slot.displayLabel(),
          isSelected: isSelected,
          onTap: () => setState(() => _selectedSlot = slot),
        );
      },
    );
  }

  Widget _buildDurationStep() {
    return ListView.separated(
      key: const ValueKey('duration-step'),
      itemCount: _availableDurations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final slots = _availableDurations[index];
        final minutes = slots * 30;
        final isSelected = _selectedDurationSlots == slots;
        return _OptionCard(
          title: SettingsStrings.minutesLabel(minutes),
          subtitle: SettingsStrings.definedByProviderAvailability,
          isSelected: isSelected,
          onTap: () => setState(() => _selectedDurationSlots = slots),
          leading: Icons.schedule,
        );
      },
    );
  }

  Widget _buildTypeStep() {
    return ListView.separated(
      key: const ValueKey('type-step'),
      itemCount: _availableSessionTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final type = _availableSessionTypes[index];
        final isSelected = _selectedSessionType == type;
        final fee = widget.doctor.consultationFee.getFeeBySType(type);
        return _OptionCard(
          title: SessionType.displayName(type),
          subtitle: fee > 0
              ? SettingsStrings.bookingFeePerSession(fee.toDouble())
              : SettingsStrings.sessionAvailableLabel,
          isSelected: isSelected,
          onTap: () => setState(() => _selectedSessionType = type),
          leading: SessionType.icon(type),
        );
      },
    );
  }

  String _titleForStep(_BookingStep step) {
    switch (step) {
      case _BookingStep.date:
        return SettingsStrings.chooseDayTitle;
      case _BookingStep.time:
        return SettingsStrings.chooseTimeTitle;
      case _BookingStep.duration:
        return SettingsStrings.chooseSessionDurationTitle;
      case _BookingStep.type:
        return SettingsStrings.chooseSessionTypeTitle;
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  final Color color;

  const _StepIndicator({
    required this.current,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i < total - 1 ? 2 : 0),
            decoration: BoxDecoration(
              color: active ? color : color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? leading;
  final Widget? trailing;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppStyles.borderRadius),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppStyles.borderRadius),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              Icon(leading, color: colorScheme.primary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.bodyMedium),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppStyles.bodySmall),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(
                Icons.circle,
                color: isSelected ? colorScheme.primary : theme.cardColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChipCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChipCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.55),
          ),
        ),
        child: Text(
          label,
          style: AppStyles.bodySmall.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
