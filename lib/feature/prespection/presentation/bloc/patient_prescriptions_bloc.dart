// lib/feature/prespection/presentation/bloc/patient_prescriptions_bloc.dart
import 'package:afiete/feature/prespection/domain/usecases/prescription_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'patient_prescriptions_event.dart';
import 'patient_prescriptions_state.dart';

class PatientPrescriptionsBloc
    extends Bloc<PatientPrescriptionsEvent, PatientPrescriptionsState> {
  final GetPatientPrescriptions getPrescriptions;
  final GetPatientPrescriptionDetail getPrescriptionDetail;
  final DownloadPrescriptionHtml downloadPrescriptionHtml;

  PatientPrescriptionsBloc({
    required this.getPrescriptions,
    required this.getPrescriptionDetail,
    required this.downloadPrescriptionHtml,
  }) : super(PatientPrescriptionsInitial()) {
    on<LoadPatientPrescriptions>(_onLoadPrescriptions);
    on<LoadPatientPrescriptionDetail>(_onLoadPrescriptionDetail);
    on<DownloadPrescriptionHtmlEvent>(_onDownloadHtml);
  }

  Future<void> _onLoadPrescriptions(
    LoadPatientPrescriptions event,
    Emitter<PatientPrescriptionsState> emit,
  ) async {
    emit(PatientPrescriptionsLoading());
    try {
      final prescriptions = await getPrescriptions();
      emit(PatientPrescriptionsLoaded(prescriptions));
    } catch (e) {
      emit(PatientPrescriptionsError(e.toString()));
    }
  }

  Future<void> _onLoadPrescriptionDetail(
    LoadPatientPrescriptionDetail event,
    Emitter<PatientPrescriptionsState> emit,
  ) async {
    emit(PatientPrescriptionDetailLoading());
    try {
      final prescription = await getPrescriptionDetail(event.id);
      emit(PatientPrescriptionDetailLoaded(prescription));
    } catch (e) {
      emit(PatientPrescriptionsError(e.toString()));
    }
  }

  Future<void> _onDownloadHtml(
    DownloadPrescriptionHtmlEvent event,
    Emitter<PatientPrescriptionsState> emit,
  ) async {
    emit(PrescriptionHtmlLoading());
    try {
      final htmlContent = await downloadPrescriptionHtml(event.id);
      emit(PrescriptionHtmlLoaded(
        htmlContent: htmlContent,
        prescriptionId: event.id,
      ));
    } catch (e) {
      emit(PrescriptionHtmlError(e.toString()));
    }
  }
}
