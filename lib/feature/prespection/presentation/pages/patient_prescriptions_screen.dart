import 'package:afiete/feature/prespection/presentation/pages/patient_prescription_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/patient_prescriptions_bloc.dart';
import '../bloc/patient_prescriptions_event.dart';
import '../bloc/patient_prescriptions_state.dart';
import '../widgets/prescription_card.dart';

class PatientPrescriptionsScreen extends StatelessWidget {
  const PatientPrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الوصفات الطبية'),
      ),
      body: BlocBuilder<PatientPrescriptionsBloc, PatientPrescriptionsState>(
        builder: (context, state) {
          if (state is PatientPrescriptionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatientPrescriptionsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PatientPrescriptionsBloc>()
                          .add(LoadPatientPrescriptions());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is PatientPrescriptionsLoaded) {
            if (state.prescriptions.isEmpty) {
              return const Center(
                child: Text('لا توجد وصفات طبية'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<PatientPrescriptionsBloc>()
                    .add(LoadPatientPrescriptions());
              },
              child: ListView.builder(
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

          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }
}
