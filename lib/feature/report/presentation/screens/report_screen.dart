import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/widget/custom_button.dart';
import 'package:afiete/feature/report/domain/entities/report_config.dart';
import 'package:afiete/feature/report/presentation/cubits/report_cubit.dart';
import 'package:afiete/feature/report/presentation/widgets/report_form_widget.dart';
import 'package:afiete/feature/report/presentation/widgets/report_reason_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportScreen extends StatefulWidget {
  final String? reportedUsername;
  final String? targetName;

  const ReportScreen({
    super.key,
    this.reportedUsername,
    this.targetName,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _contentController = TextEditingController();
  ReasonItem? _selectedReason;
  String _selectedUserReportType = 'doctor';

  @override
  void initState() {
    super.initState();
    context.read<ReportCubit>().loadReportsDashboard();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitAction() {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء كتابة تفاصيل البلاغ")),
      );
      return;
    }

    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء اختيار سبب البلاغ")),
      );
      return;
    }

    final cubit = context.read<ReportCubit>();

    if (widget.reportedUsername != null) {
      cubit.submitUserReport(
        reportType: _selectedUserReportType,
        targetName: widget.reportedUsername!,
        reason: _selectedReason!.key,
        description: _contentController.text.trim(),
      );
    } else {
      cubit.submitAppReport(
        reason: _selectedReason!.key,
        description: _contentController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserReporting = widget.reportedUsername != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            isUserReporting ? "إبلاغ عن مخالفة سلوكية" : "بلاغ تقني / اقتراح"),
      ),
      body: BlocConsumer<ReportCubit, ReportState>(
        listener: (context, state) {
          if (state is ReportSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pop(context, true);
          } else if (state is ReportsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ReportsDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ReasonItem> availableReasons = [];
          if (state is ReportsDashboardLoaded) {
            availableReasons = isUserReporting
                ? (state.config.reasons['user'] ?? [])
                : (state.config.reasons['app'] ?? []);
          }

          return ListView(
            padding: const EdgeInsets.all(AppStyles.padding),
            children: [
              if (isUserReporting) ...[
                // تنبيه للمستخدم
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "أنت تقوم بتقديم بلاغ ضد: ${widget.targetName ?? 'هذا المستخدم'}.\nسيتم التحقق من وجود جلسة مشتركة بينكما.",
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // عنوان قسم اختيار النوع
                Text(
                  "اختر نوع البلاغ:",
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // خيارات نوع البلاغ مع الوصف
                _buildReportTypeCard(
                  context: context,
                  value: 'doctor',
                  title: 'بلاغ عن طبيب',
                  description:
                      'استخدم هذا الخيار للإبلاغ عن سلوك غير مهني أو مخالفات من الطبيب نفسه',
                  icon: Icons.medical_services,
                  isSelected: _selectedUserReportType == 'doctor',
                ),
                const SizedBox(height: 12),
                _buildReportTypeCard(
                  context: context,
                  value: 'session',
                  title: 'بلاغ عن جلسة/موعد',
                  description:
                      'استخدم هذا الخيار للإبلاغ عن مشاكل متعلقة بموعد محدد (عدم الحضور، إلغاء متأخر، إلخ)',
                  icon: Icons.event_busy,
                  isSelected: _selectedUserReportType == 'session',
                ),
                const SizedBox(height: 20),
              ],

              // عنوان قسم اختيار السبب
              Text(
                "اختر سبب البلاغ:",
                style: AppStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              availableReasons.isEmpty
                  ? const Text("جاري جلب قائمة الأسباب...")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: availableReasons.length,
                      itemBuilder: (context, index) {
                        final reason = availableReasons[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: CustomReportReasonCard(
                            label: reason.label,
                            icon: isUserReporting ? 'block' : 'bug_report',
                            isSelected: _selectedReason?.key == reason.key,
                            onTap: () =>
                                setState(() => _selectedReason = reason),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 20),

              // حقل التفاصيل
              CustomReportFormWidget(
                label: "شرح تفصيلي للمشكلة",
                hintText: "يرجى كتابة تفاصيل دقيقة لمساعدتنا في التحقيق...",
                controller: _contentController,
              ),
              const SizedBox(height: 24),

              // زر الإرسال
              CustomButton(
                widget: state is ReportActionLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "إرسال البلاغ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                onPressed: state is ReportActionLoading ? null : _submitAction,
              ),
            ],
          );
        },
      ),
    );
  }

  // دالة لبناء بطاقة اختيار نوع البلاغ مع الوصف
  Widget _buildReportTypeCard({
    required BuildContext context,
    required String value,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => setState(() => _selectedUserReportType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الأيقونة
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // النص والعنوان
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
