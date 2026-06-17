enum ReportType {
  app, // بلاغ موجه للتطبيق ككل (مشاكل تقنية، دفع، إلخ)
  doctor, // بلاغ سلوكي ضد طبيب من ملفه الشخصي
  session, // بلاغ متعلق بجلسة أو موعد معين
}

extension ReportTypeExtension on ReportType {
  String get value {
    switch (this) {
      case ReportType.app:
        return 'app';
      case ReportType.doctor:
        return 'doctor';
      case ReportType.session:
        return 'session';
    }
  }

  static ReportType fromString(String type) {
    switch (type) {
      case 'doctor':
        return ReportType.doctor;
      case 'session':
        return ReportType.session;
      case 'app':
      default:
        return ReportType.app;
    }
  }
}
