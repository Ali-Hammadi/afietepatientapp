import 'package:afiete/feature/report/domain/entities/report_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/styles.dart';

class CustomReportCard extends StatelessWidget {
  final dynamic report; // يمكن أن يكون AppReport أو UserReport
  final VoidCallback? onTap;

  const CustomReportCard({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isAppReport = report is AppReport;

    // استخراج النصوص بحسب النوع
    final String title = isAppReport
        ? (report as AppReport).title
        : "بلاغ سلوكي ضد: ${(report as UserReport).reportedUsername}";

    final String content = report.content;
    final DateTime createdAt = report.createdAt;

    // تحديد الشارة الجانبية للحالة
    final String statusLabel = isAppReport
        ? ((report as AppReport).isResolved ? "محلولة" : "قيد المعالجة")
        : _getUserActionLabel((report as UserReport).actionTaken);

    final Color statusColor = isAppReport
        ? ((report as AppReport).isResolved ? Colors.green : Colors.orange)
        : ((report as UserReport).actionTaken == 'NONE'
            ? Colors.blue
            : Colors.red);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.borderRadius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: AppStyles.bodySmall.copyWith(
                          color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.75)),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تاريخ البلاغ: ${DateFormat('yyyy-MM-dd').format(createdAt)}',
                    style: AppStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 14, color: colorScheme.outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getUserActionLabel(String action) {
    switch (action) {
      case 'NONE':
        return 'قيد المراجعة الإدارية';
      case 'FUNDS_FROZEN':
        return 'تم تجميد المحفظة ماليًا';
      case 'ACCOUNT_SUSPENDED':
        return 'تم تعليق حساب المشكو عليه';
      case 'ACCOUNT_DELETED':
        return 'تم حظر المشكو عليه نهائياً';
      case 'DISMISSED':
        return 'تم حفظ البلاغ / لم يثبت إدانة';
      default:
        return 'تحت التحقيق';
    }
  }
}
