import 'package:afiete/feature/report/data/config/report_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/styles.dart';
import '../../../../core/widget/custom_button.dart';
import '../cubits/report_cubit.dart';
import '../widgets/report_form_widget.dart';
import '../widgets/report_reason_card.dart';

class ReportScreen extends StatefulWidget {
  final String?
      reportedUsername; // إذا وجد يعني بلاغ ضد يوزر، إذا فرغ يعني بلاغ تقني للتطبيق
  final String? targetName; // اسم الطبيب أو المريض المشتكى عليه للعرض الشكلي

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
  final TextEditingController _titleController =
      TextEditingController(); // خاص ببلاغات التطبيق فقط

  ReasonItem? _selectedReason;
  String _selectedAppType = "BUG"; // الافتراضي لبلاغات التطبيق

  @override
  void initState() {
    super.initState();
    // إعادة تنشيط وضمان تحميل أحدث تكوين للأسباب من السيرفر
    context.read<ReportCubit>().loadReportsDashboard();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _submitAction() {
    final cubit = context.read<ReportCubit>();
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("الرجاء كتابة تفاصيل المشكلة أو البلاغ")));
      return;
    }

    if (widget.reportedUsername != null) {
      cubit.submitUserReport(
        reportedUsername: widget.reportedUsername!,
        content:
            "السبب: ${_selectedReason?.label ?? 'غير محدد'} - التفاصيل: ${_contentController.text}",
      );
    } else {
      // 2. إرسال بلاغ فني تقني أو اقتراح يخص التطبيق ككل
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("الرجاء كتابة عنوان البلاغ التقني")));
        return;
      }
      cubit.submitAppReport(
        reportType: _selectedAppType,
        title: _titleController.text,
        content: _contentController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUserReporting = widget.reportedUsername != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUserReporting
            ? "إبلاغ عن مخالفة سلوكية"
            : "إرسال بلاغ تقني / اقتراح"),
      ),
      body: BlocConsumer<ReportCubit, ReportState>(
        listener: (context, state) {
          if (state is ReportSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.green));
            context
                .read<ReportCubit>()
                .loadReportsDashboard(); // تحديث السجل فوراً
            Navigator.pop(context);
          } else if (state is ReportsError) {
            // هنا يظهر الخطأ الأمني الصادر من الباك إند (مثال: غياب الجلسة المشتركة بين المستخدمين)
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is ReportsDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // استخراج قوائم الأسباب الديناميكية عند اكتمال تحميل التكوين من السيرفر
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    "أنت تقوم بتقديم بلاغ رسمي ضد: ${widget.targetName ?? 'هذا المستخدم'}.\nملاحظة: سيتحقق النظام تلقائياً من وجود جلسة مشتركة بينكما لضمان مصداقية البلاغ.",
                    style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (!isUserReporting) ...[
                // واجهة اختيار نوع بلاغ التطبيق (فني / اقتراح)
                DropdownButtonFormField<String>(
                  value: _selectedAppType,
                  decoration:
                      const InputDecoration(labelText: "نوع البلاغ الفني"),
                  items: const [
                    DropdownMenuItem(
                        value: "BUG",
                        child: Text("Technical Bug / عطل فني في التطبيق")),
                    DropdownMenuItem(
                        value: "SUGGESTION",
                        child: Text("Suggestion / اقتراح وتطوير")),
                    DropdownMenuItem(
                        value: "OTHER", child: Text("Other / أمور أخرى")),
                  ],
                  onChanged: (val) =>
                      setState(() => _selectedAppType = val ?? "BUG"),
                ),
                const SizedBox(height: 16),
                CustomReportFormWidget(
                  label: "عنوان المشكلة",
                  hintText: "اكتب عنواناً مختصراً للمشكلة التقنية...",
                  controller: _titleController,
                  maxLines: 1,
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
              ],
              Text("اختر سبب البلاغ الأساسي المعتمد ديناميكياً:",
                  style: AppStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              availableReasons.isEmpty
                  ? const Text(
                      "جاري جلب قائمة الأسباب المعتمدة من خوادم النظام...")
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
              const SizedBox(height: 16),
              CustomReportFormWidget(
                label: "شرح تفصيلي للمشكلة",
                hintText:
                    "يرجى كتابة تفاصيل دقيقة لمساعدتنا في التحقيق الفوري...",
                controller: _contentController,
              ),
              const SizedBox(height: 24),
              CustomButton(
                widget: state is ReportActionLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("إرسال البلاغ فوراً للإدارة",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: state is ReportActionLoading ? null : _submitAction,
              ),
            ],
          );
        },
      ),
    );
  }
}
