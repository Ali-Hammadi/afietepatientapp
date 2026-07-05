// lib/feature/prespection/presentation/pages/patient_prescription_detail_page.dart
import 'dart:io';
import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_bloc.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_event.dart';
import 'package:afiete/feature/prespection/presentation/bloc/patient_prescriptions_state.dart';
import 'package:afiete/feature/prespection/presentation/widgets/medecine_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  bool _showHtmlView = false;
  String? _htmlContent;

  @override
  void initState() {
    super.initState();
    context.read<PatientPrescriptionsBloc>().add(
          LoadPatientPrescriptionDetail(widget.prescriptionId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<PatientPrescriptionsBloc, PatientPrescriptionsState>(
      listener: (context, state) {
        if (state is PrescriptionHtmlLoaded) {
          setState(() {
            _showHtmlView = true;
            _htmlContent = state.htmlContent;
          });
        } else if (state is PrescriptionHtmlError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (_showHtmlView && _htmlContent != null) {
          return _buildHtmlViewer(colorScheme);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(SettingsStrings.prescriptionDetails),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded),
                tooltip: SettingsStrings.viewPrescription,
                onPressed: () {
                  context.read<PatientPrescriptionsBloc>().add(
                        DownloadPrescriptionHtmlEvent(widget.prescriptionId),
                      );
                },
              ),
            ],
          ),
          body: _buildBody(state, colorScheme),
        );
      },
    );
  }

  Widget _buildBody(PatientPrescriptionsState state, ColorScheme colorScheme) {
    if (state is PatientPrescriptionDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PatientPrescriptionsError) {
      return _buildErrorState(colorScheme, state.message);
    }

    if (state is PatientPrescriptionDetailLoaded) {
      final prescription = state.prescription;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Prescription Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prescription.prescriptionNumber,
                              style: AppStyles.headingSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy - HH:mm',
                                SettingsStrings.isArabic ? 'ar' : 'en',
                              ).format(prescription.createdAt),
                              style: AppStyles.bodySmall.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.event_note_rounded,
                    SettingsStrings.appointmentNumber,
                    '#${prescription.appointmentId}',
                    colorScheme,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.person_outline_rounded,
                    SettingsStrings.doctor,
                    prescription.doctorUsername,
                    colorScheme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              context,
              icon: Icons.assignment_outlined,
              title: SettingsStrings.diagnosisLabel,
              content: prescription.diagnosis,
            ),

            if (prescription.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildSectionCard(
                context,
                icon: Icons.notes_rounded,
                title: SettingsStrings.notesLabel,
                content: prescription.notes,
              ),
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: colorScheme.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${SettingsStrings.medications} (${prescription.medications.length})',
                  style: AppStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...prescription.medications.map(
              (medication) => MedicationTile(medication: medication),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<PatientPrescriptionsBloc>().add(
                        DownloadPrescriptionHtmlEvent(widget.prescriptionId),
                      );
                },
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: Text(
                  SettingsStrings.viewPrescription,
                  style: AppStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return const Center(child: Text('No data available'));
  }

  Widget _buildErrorState(ColorScheme colorScheme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<PatientPrescriptionsBloc>().add(
                    LoadPatientPrescriptionDetail(widget.prescriptionId),
                  ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(SettingsStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 18, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.bodySmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: AppStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ HTML Viewer
  Widget _buildHtmlViewer(ColorScheme colorScheme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsStrings.prescriptionDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            setState(() {
              _showHtmlView = false;
              _htmlContent = null;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: SettingsStrings.retry,
            onPressed: () {
              context.read<PatientPrescriptionsBloc>().add(
                    DownloadPrescriptionHtmlEvent(widget.prescriptionId),
                  );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Html(
            data: _htmlContent!,
            style: {
              "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              "html": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // ✅ زر مشاركة
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sharePrescription(),
                  icon: const Icon(Icons.share_rounded),
                  label: Text(
                    SettingsStrings.sharePrescription,
                    style: AppStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ✅ زر حفظ HTML
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _saveHtmlFile(),
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    'Save HTML',
                    style: AppStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// ✅ مشاركة الوصفة
  Future<void> _sharePrescription() async {
    if (_htmlContent == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/prescription.html');
      await file.writeAsString(_htmlContent!);

      // التعديل هنا: استخدام Share.shareXFiles
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Medical Prescription',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ حفظ HTML في الجهاز
  Future<void> _saveHtmlFile() async {
    if (_htmlContent == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName =
          'Prescription_${DateTime.now().millisecondsSinceEpoch}.html';
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsString(_htmlContent!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to Downloads: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
