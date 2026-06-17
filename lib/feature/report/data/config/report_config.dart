import 'package:equatable/equatable.dart';

class ReportConfig extends Equatable {
  final List<String> reportTypes;
  final Map<String, List<ReasonItem>> reasons;

  const ReportConfig({required this.reportTypes, required this.reasons});

  @override
  List<Object?> get props => [reportTypes, reasons];
}

class ReasonItem extends Equatable {
  final String key;
  final String label;

  const ReasonItem({required this.key, required this.label});

  @override
  List<Object?> get props => [key, label];
}
