import 'package:afiete/feature/prespection/presentation/widgets/medecine_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/patient_prescriptions_bloc.dart';
import '../bloc/patient_prescriptions_event.dart';
import '../bloc/patient_prescriptions_state.dart';

class PatientPrescriptionDetailPage extends StatefulWidget {
  final dynamic prescriptionId;

  const PatientPrescriptionDetailPage({
    super.key,
    required this.prescriptionId,
  });

  @override
  State<PatientPrescriptionDetailPage> createState() =>
      _PatientPrescriptionDetailPageState();
}

class _PatientPrescriptionDetailPageState
    extends State<PatientPrescriptionDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<PatientPrescriptionsBloc>().add(
          LoadPatientPrescriptionDetail(widget.prescriptionId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الوصفة'),
      ),
      body: BlocBuilder<PatientPrescriptionsBloc, PatientPrescriptionsState>(
        builder: (context, state) {
          if (state is PatientPrescriptionDetailLoading) {
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
                ],
              ),
            );
          }

          if (state is PatientPrescriptionDetailLoaded) {
            final prescription = state.prescription;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prescription.prescriptionNumber,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                              'رقم الموعد', '#${prescription.appointmentId}'),
                          _buildInfoRow(
                            'التاريخ',
                            DateFormat('yyyy/MM/dd - HH:mm')
                                .format(prescription.createdAt),
                          ),
                          const Divider(height: 24),
                          const Text(
                            'التشخيص',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(prescription.diagnosis),
                          if (prescription.notes.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'ملاحظات',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(prescription.notes),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'الأدوية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...prescription.medications.map(
                    (medication) => MedicationTile(medication: medication),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
