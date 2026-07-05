// lib/feature/prespection/presentation/pages/patient_prescriptions_screen.dart
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_bloc.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_event.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_state.dart';
import 'package:afiete/feature/prespection/presentation/pages/patient_prescription_detail_page.dart';
import 'package:afiete/feature/prespection/presentation/widgets/prescription_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientPrescriptionsScreen extends StatelessWidget {
  const PatientPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsStrings.prescriptions),
      ),
      body: BlocBuilder<PatientPrescriptionsBloc, PatientPrescriptionsState>(
        builder: (context, state) {
          if (state is PatientPrescriptionsLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state is PatientPrescriptionsError) {
            return _buildErrorState(context, colorScheme, state.message);
          }

          if (state is PatientPrescriptionsLoaded) {
            if (state.prescriptions.isEmpty) {
              return _buildEmptyState(colorScheme);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<PatientPrescriptionsBloc>()
                    .add(LoadPatientPrescriptions());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.prescriptions.length,
                itemBuilder: (context, index) {
                  final prescription = state.prescriptions[index];
                  return PrescriptionCard(
                    prescription: prescription,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientPrescriptionDetailPage(
                            prescriptionId: prescription.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, ColorScheme colorScheme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<PatientPrescriptionsBloc>()
                    .add(LoadPatientPrescriptions());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(SettingsStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              SettingsStrings.noPrescriptions,
              style: AppStyles.headingSmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
