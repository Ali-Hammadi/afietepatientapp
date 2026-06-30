import 'package:afiete/core/constants/styles.dart';
import 'package:afiete/core/ln10/settings_strings.dart';
import 'package:afiete/core/routes/app_route.dart';
import 'package:flutter/material.dart';

class ReportIssueScreen extends StatelessWidget {
  const ReportIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          SettingsStrings.reportIssueTitle,
          style: AppStyles.headingMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "اختر نوع البلاغ الذي تريد تقديمه. جميع البلاغات سرية وستتم مراجعتها من قبل الإدارة.",
                        style: AppStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "أنواع البلاغات المتاحة:",
                style: AppStyles.headingMedium,
              ),
              const SizedBox(height: 16),

              // بطاقة البلاغ التقني
              _buildReportTypeCard(
                context: context,
                icon: Icons.bug_report,
                title: "بلاغ تقني / اقتراح",
                description:
                    "الإبلاغ عن مشكلة في التطبيق أو تقديم اقتراح للتحسين",
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    MyRoutes.reportScreen,
                    // بدون arguments = بلاغ تقني
                  );
                },
              ),
              const SizedBox(height: 12),

              // بطاقة البلاغ عن طبيب
              _buildReportTypeCard(
                context: context,
                icon: Icons.medical_services,
                title: "بلاغ عن طبيب",
                description: "الإبلاغ عن سلوك غير مهني أو مخالفات من طبيب",
                onTap: () => _showUsernameInputDialog(
                  context,
                  reportType: 'doctor',
                  title: "أدخل اسم المستخدم الخاص بالطبيب",
                ),
              ),
              const SizedBox(height: 12),

              // بطاقة البلاغ عن جلسة
              _buildReportTypeCard(
                context: context,
                icon: Icons.event_busy,
                title: "بلاغ عن جلسة/موعد",
                description:
                    "الإبلاغ عن مشكلة في موعد محدد (عدم حضور، إلغاء متأخر)",
                onTap: () => _showUsernameInputDialog(
                  context,
                  reportType: 'session',
                  title: "أدخل اسم المستخدم الخاص بالطبيب/المريض",
                ),
              ),
              const SizedBox(height: 16),

              // زر عرض سجل البلاغات
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, MyRoutes.reportHistoryScreen);
                },
                icon: const Icon(Icons.history),
                label: const Text("عرض سجل البلاغات السابقة"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.outline,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showUsernameInputDialog(
    BuildContext context, {
    required String reportType,
    required String title,
  }) {
    final usernameController = TextEditingController();
    final displayNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "اسم المستخدم (Username)",
                hintText: "مثال: dr_ahmed_123",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: "الاسم المعروض (اختياري)",
                hintText: "مثال: د. أحمد محمد",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              final username = usernameController.text.trim();
              if (username.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("الرجاء إدخال اسم المستخدم")),
                );
                return;
              }

              Navigator.pop(dialogContext);
              Navigator.pushNamed(
                context,
                MyRoutes.reportScreen,
                arguments: ReportScreenArgs(
                  reportedUsername: username,
                  targetName: displayNameController.text.trim().isEmpty
                      ? username
                      : displayNameController.text.trim(),
                ),
              );
            },
            child: const Text("متابعة"),
          ),
        ],
      ),
    );
  }
}
