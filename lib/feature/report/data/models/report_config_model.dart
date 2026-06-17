import 'package:afiete/feature/report/data/config/report_config.dart';

class ReportConfigModel extends ReportConfig {
  const ReportConfigModel({required super.reportTypes, required super.reasons});

  factory ReportConfigModel.fromJson(Map<String, dynamic> json) {
    final reportTypesList = List<String>.from(json['reportTypes'] ?? []);
    final reasonsMap = <String, List<ReasonItem>>{};

    if (json['reasons'] != null) {
      json['reasons'].forEach((key, value) {
        reasonsMap[key] = (value as List)
            .map((item) => ReasonItemModel.fromJson(item))
            .toList();
      });
    }
    return ReportConfigModel(reportTypes: reportTypesList, reasons: reasonsMap);
  }
}

class ReasonItemModel extends ReasonItem {
  const ReasonItemModel({required super.key, required super.label});
  factory ReasonItemModel.fromJson(Map<String, dynamic> json) {
    return ReasonItemModel(key: json['key'] ?? '', label: json['label'] ?? '');
  }
}
