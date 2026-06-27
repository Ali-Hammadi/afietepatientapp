import 'package:afiete/core/constants/payment_methods.dart';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/constants/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:afiete/feature/auth/presentation/cubits/auth_cubit.dart';
import 'package:afiete/feature/appointments/presentation/cubits/appointments_cubit.dart';
import 'package:afiete/feature/doctors/domain/entities/doctor_entity.dart';
import 'package:afiete/feature/doctors/presentation/cubits/doctors_cubit.dart';
import 'package:afiete/feature/payment/domain/entities/payment_request_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum _RescheduleStep {
  date,
  time,
}

class RescheduleSessionScreen extends StatefulWidget {
  final DoctorEntity doctor;
  final bool rescheduleMode;

  const RescheduleSessionScreen({
    super.key,
    required this.doctor,
    this.rescheduleMode = false,
  });

  @override
  State<RescheduleSessionScreen> createState() =>
      _RescheduleSessionScreenState();
}

class _RescheduleSessionScreenState extends State<RescheduleSessionScreen> {
  _RescheduleStep _step = _RescheduleStep.date;
  DateTime? _selectedDate;
  DoctorTimeSlot? _selectedSlot;
  List<DoctorTimeSlot> _daySlots = const [];

  // متغيرات التصفية المسبقة والتحميل الشامل للأيام
  Map<DateTime, List<DoctorTimeSlot>> _allDaysSlotsMap = {};
  List<DateTime> _filteredDays = [];
  bool _isLoadingAllDays = true;

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

  @override
  void initState() {
    super.initState();
    _preFetchAndFilterAvailableDays();
  }

  Future<void> _preFetchAndFilterAvailableDays() async {
    setState(() => _isLoadingAllDays = true);

    final doctorUsername = widget.doctor.doctorUsername;
    final days = _nextDays;

    try {
      final doctorsCubit = context.read<DoctorsCubit>();

      final results = await Future.wait(days
          .map((day) => doctorsCubit.fetchSlotsForDate(doctorUsername, day)));

      final Map<DateTime, List<DoctorTimeSlot>> tempMap = {};
      for (int i = 0; i < days.length; i++) {
        tempMap[days[i]] = results[i];
      }

      if (!mounted) return;

      setState(() {
        _allDaysSlotsMap = tempMap;
        _filteredDays = days.where((day) {
          final slots = _allDaysSlotsMap[day] ?? [];
          return slots.isNotEmpty;
        }).toList();

        _isLoadingAllDays = false;

        if (_filteredDays.isNotEmpty) {
          _selectedDate = _filteredDays.first;
          _daySlots = _allDaysSlotsMap[_selectedDate] ?? [];
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingAllDays = false);
    }
  }

  bool get _canContinue {
    switch (_step) {
      case _RescheduleStep.date:
        return _selectedDate != null &&
            _filteredDays.isNotEmpty &&
            !_isLoadingAllDays;
      case _RescheduleStep.time:
        return _selectedSlot != null;
    }
  }

  Future<void> _onContinuePressed() async {
    switch (_step) {
      case _RescheduleStep.date:
        setState(() => _step = _RescheduleStep.time);
        return;
      case _RescheduleStep.time:
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

      Navigator.pop(context, {
        'selectedTime': scheduledAt,
      });
      return;
    } else {
      setState(() {});

      final authState = context.read<AuthCubit>().state;
      String patientUsername = 'unknown-patient';
      if (authState is AuthLoaded) {
        patientUsername = authState.user.patientUsername;
      } else if (authState is AuthProfileUpdated) {
        patientUsername = authState.user.patientUsername;
      }

      final generatedAppointmentId =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final cubit = context.read<AppointmentsCubit>();
      await cubit.createAppointmentDraft(
        appointmentId: generatedAppointmentId,
        doctorUsername: widget.doctor.doctorUsername,
        patientUsername: patientUsername,
        doctorName: widget.doctor.name ?? 'Doctor',
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
        SnackBar(
            content: Text(SettingsStrings.bookingDraftCreatedSuccessfully)),
      );

      final amount = widget.doctor.consultationFee.getFeeBySType(
        _selectedSessionType!,
      );

      Navigator.pushNamed(
        context,
        MyRoutes.paymentScreen,
        arguments: PaymentRequestEntity(
          appointmentId: generatedAppointmentId,
          doctorName: widget.doctor.name ?? 'Doctor',
          scheduledAt: scheduledAt,
          sessionType: _selectedSessionType!,
          amount: amount,
          currency: 'USD',
          method: PaymentMethod.card,
        ),
      );
    }
  }

  void _onBack() {
    switch (_step) {
      case _RescheduleStep.date:
        Navigator.pop(context);
        return;
      case _RescheduleStep.time:
        setState(() => _step = _RescheduleStep.date);

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
            total: _RescheduleStep.values.length,
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
            if (_step == _RescheduleStep.time && _selectedDate != null)
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
                      _step == _RescheduleStep.date
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
      case _RescheduleStep.date:
        return _buildDateStep(localeCode);
      case _RescheduleStep.time:
        return _buildTimeStep(localeCode);
    }
  }

  Widget _buildDateStep(String localeCode) {
    if (_isLoadingAllDays) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredDays.isEmpty) {
      return Center(
        child: Text(
          SettingsStrings.noAvailableTimesForThisDate,
          style: AppStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      key: const ValueKey('date-step'),
      itemCount: _filteredDays.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final day = _filteredDays[index];
        final isSelected =
            _selectedDate != null && DateUtils.isSameDay(_selectedDate, day);
        final isToday = DateUtils.isSameDay(day, DateTime.now());
        final currentDaySlots = _allDaysSlotsMap[day] ?? [];

        Widget? trailing;
        if (isSelected) {
          trailing = Text(
            '${currentDaySlots.length} slots',
            style: AppStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        return;
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

  String _titleForStep(_RescheduleStep step) {
    switch (step) {
      case _RescheduleStep.date:
        return SettingsStrings.chooseDayTitle;
      case _RescheduleStep.time:
        return SettingsStrings.chooseTimeTitle;
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
